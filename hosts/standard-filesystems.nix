# Standardised filesystem layout.
# Assumes standardised naming documented in /docs/disk_security.md.

# TODO: disable default zpool logic, do explicit zpool imports to avoid e.g. `import -a`, `load-keys -a` which break on e.g. clones of encrypted datasets.

{ lib, config, ... }:
let
  cfg = config.standard_filesystems;
in
{
  options.standard_filesystems = {
    tmpfs_size = lib.mkOption {
      type = lib.types.str;
      default = "4G";
    };
    partuuids = {
      zfskeys = lib.mkOption {
        type = lib.types.str;
      };
      swap = lib.mkOption {
        type = lib.types.str;
      };
      boot = lib.mkOption {
        type = lib.types.str;
      };
    };
    pool_names = {
      root = lib.mkOption {
        default = "zroot";
        readOnly = true;
        type = lib.types.str;
      };
      zfskeys = lib.mkOption {
        default = "zfskeys";
        readOnly = true;
        type = lib.types.str;
      };
    };
  };

  config = {
    boot.initrd = {
      luks.devices = {
        "zfskeys".device = "/dev/disk/by-partuuid/${cfg.partuuids.zfskeys}";
        "swap".device = "/dev/disk/by-partuuid/${cfg.partuuids.swap}";
      };

      systemd.services.zfskeybootstrap = {
        wantedBy = [ "initrd.target" ];
        after = [ "cryptsetup.target" ];
        # Finish loading keys to the pools before starting the ZFS mounts
        before = [
          "zfs-import-${cfg.pool_names.root}.service"
          "sysroot.mount"
        ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";

        # We need to make these available before the root filesystem mount, because
        # the root filesystem is encrypted using these keys.
        #
        # The LUKS device remains opened, which makes it clearer what the partition
        # is and allows easier mounting if new keys are needed.
        script = ''
          echo "Loading bootstrap keys"
          zpool import -f ${cfg.pool_names.zfskeys}
          zpool scrub -w ${cfg.pool_names.zfskeys}
          mkdir -p /zfskeys
          mount -t zfs -o ro ${cfg.pool_names.zfskeys} /zfskeys

          echo "Loading ZFS pools and keys"
          zpool import -f -a
          zfs load-key -a

          echo "Unloading bootstrap keys"
          umount /zfskeys
          # This shouldn't fail the script.
          rmdir /zfskeys || echo "Dirty zfskeys directory"
          zpool export ${cfg.pool_names.zfskeys}
        '';
      };
    };

    swapDevices = [ { device = "/dev/mapper/swap"; } ];

    fileSystems = {
      "/boot" = {
        device = "/dev/disk/by-partuuid/${cfg.partuuids.boot}";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      "/" = {
        # Overriden in impermanent setups.
        device = "${cfg.pool_names.root}/enc/snap/root";
        fsType = "zfs";
        neededForBoot = true;
      };

      "/home/keith" = {
        device = "${cfg.pool_names.root}/enc/snap/home/keith";
        fsType = "zfs";
      };

      "/nix" = {
        device = "${cfg.pool_names.root}/enc/snap/nix";
        fsType = "zfs";
      };

      "/tmp" = {
        device = "none";
        fsType = "tmpfs";
        options = [
          "size=${cfg.tmpfs_size}"
          "noatime"
        ];
      };
    };

    # There's quite a few steps to manually mount the above filesystems. Write helper scripts
    # prefilled with the right UUIDs to the unencrypted easy-to-access /boot partition.
    #
    # Ideally would use a systemd oneshot service, which runs on every activation. However,
    # these scripts are most useful on first boot after `nixos-install`, which would be before
    # systemd has had a chance to run to create them, so for this specific usecase activationScripts
    # is better.
    system.activationScripts.writeBootRecoveryScript = {
      text =
        let
          # Convert attrsets like:
          #   "/nix" = { device = "foo/nix"; }
          # into:
          #   "mount -tzfs foo/nix /os/nix"
          # for the specific volumes we care about.
          # This logic makes the "include /persist" if it exists case neater.
          volumesToMount = [
            "/"
            "/nix"
            "/home/keith"
            "/persist"
          ];
          requiredMounts = lib.attrsets.filterAttrs (p: _: builtins.elem p volumesToMount) config.fileSystems;
          toMountCommand = mountpoint: attrs: "mount -tzfs ${attrs.device} /os${mountpoint}";
          mountCommands = lib.strings.concatLines (lib.attrsets.mapAttrsToList toMountCommand requiredMounts);
        in
        ''
          cat > /boot/mount_recovery.sh <<EOF
          if (( \$EUID != 0 )); then
              echo "Not root"
              exit
          fi
          set -e
          set -x

          # Unlock the LUKS volume containing ZFS keys.
          systemd-cryptsetup attach ${cfg.pool_names.zfskeys} '/dev/disk/by-partuuid/${cfg.partuuids.zfskeys}'
          zpool import -f ${cfg.pool_names.zfskeys}
          # Make sure the partition is healthy.
          zpool scrub -w ${cfg.pool_names.zfskeys}
          mkdir -p /zfskeys
          mount -t zfs -o ro ${cfg.pool_names.zfskeys} /zfskeys

          # Import root
          zpool import -f zroot
          zfs load-key zroot/enc

          # Mount everything on /os
          mkdir -p /os
          mount "/dev/disk/by-partuuid/${cfg.partuuids.boot}" /os/boot
          ${mountCommands}
          echo 'System mounted on /os'
          EOF

          cat > /boot/unmount_recovery.sh <<EOF
          if (( \$EUID != 0 )); then
              echo "Not root"
              exit
          fi
          set -e
          set -x

          umount /os/boot
          # This handles unmounting any datasets that are mounted.
          # We need to export when we're done so that on next boot the OS can import them.
          zpool export -a
          systemd-cryptsetup detach ${cfg.pool_names.zfskeys}
          rmdir /os /zfskeys
          EOF

          chmod u+x /boot/mount_recovery.sh /boot/unmount_recovery.sh
        '';
    };
  };
}
