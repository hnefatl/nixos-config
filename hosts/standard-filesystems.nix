# Standardised filesystem layout.
# Assumes standardised naming documented in /docs/disk_security.md.

{ config, pkgs, lib, utils, ... }:
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
    pools = {
      root = lib.mkOption {
        default = "zroot";
        readOnly = true;
        type = lib.types.str;
      };
    };
  };

  config = {
    # TODO: configure hashed password for getting root access if initrd fails to boot. Would need to rotate etc.

    boot.initrd = {
      luks.devices = {
        # These devices survive the stage1->2 transition since they're kernel-internal.
        "zfskeys".device = "/dev/disk/by-partuuid/${cfg.partuuids.zfskeys}";
        # Swap needs to be available in stage1 to support hibernation.
        "swap".device = "/dev/disk/by-partuuid/${cfg.partuuids.swap}";
      };

      systemd.mounts = [
        {
          # In stage 1, mount /zfskeys outside the /sysroot that's going to be chroot'd into, so that they're available
          # for zroot decryption.
          # Trying to mount in a less explicit way ends up with the mountpoint being inside /sysroot, which creates a
          # cyclic dependency since zroot is mounted to /sysroot, but importing zroot requires keys mounted inside
          # /sysroot/zfskeys.
          what = "/dev/mapper/zfskeys";
          where = "/zfskeys";
          type = "ext4";
          options = "ro";
          wants = [ "cryptsetup.target" ];
          after = [ "cryptsetup.target" ];
          wantedBy = [ "zfs-import-zroot.service" ];
          before = [ "zfs-import-zroot.service" ];
          # Unmount before the chroot to avoid leaving a dangling mount.
          conflicts = [ "initrd-switch-root.target" ];
        }
        {
          # Also mount keys into /sysroot/zfskeys, so they're available in stage 2. Doing it in stage 1 avoids needing
          # to set up systemd dependencies for stage2 zfs imports.
          what = "/dev/mapper/zfskeys";
          where = "/sysroot/zfskeys";
          type = "ext4";
          options = "ro";
          wants = [ "cryptsetup.target" ];
          after = [ "cryptsetup.target" ];
          wantedBy = [ "initrd-switch-root.target" ];
          before = [ "initrd-switch-root.target" ];
        }
      ];

      # Ext4 is mandatory for mounting the ext4 zfskeys partition.
      # The other modules and programs are just nice-to-have, recovery is hard without them.
      kernelModules = [ "ext4" "fat" "vfat" ];
      systemd.extraBin = {
        vi = "${pkgs.busybox}/bin/vi";
      };
    };

    swapDevices = [ { device = "/dev/mapper/swap"; } ];

    boot.zfs = {
      # Only try to decrypt these datasets.
      requestEncryptionCredentials = [ "${cfg.pools.root}/enc" ];
      # Helps recover after tinkering.
      forceImportRoot = lib.mkForce true;
    };

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
        device = "${cfg.pools.root}/enc/snap/root";
        fsType = "zfs";
        neededForBoot = true;
      };

      "/home/keith" = {
        device = "${cfg.pools.root}/enc/snap/home/keith";
        fsType = "zfs";
      };

      "/nix" = {
        device = "${cfg.pools.root}/enc/snap/nix";
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
          systemd-cryptsetup attach zfskeys '/dev/disk/by-partuuid/${cfg.partuuids.zfskeys}'
          mkdir -p /zfskeys
          mount -o ro /dev/mapper/zfskeys /zfskeys

          # Import root
          zpool import -f ${cfg.pools.root}
          zfs load-key ${cfg.pools.root}/enc

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
          systemd-cryptsetup detach zfskeys
          rmdir /os /zfskeys
          EOF

          chmod u+x /boot/mount_recovery.sh /boot/unmount_recovery.sh
        '';
    };
  };
}
