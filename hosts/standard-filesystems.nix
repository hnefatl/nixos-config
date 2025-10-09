# Standardised filesystem layout.
# Assumes standardised naming documented in /docs/disk_security.md.

{ lib, config, ... }:
let
  cfg = config.standard_filesystems;
  root_pool = "zroot";
  key_pool = "zfskeys";
in
{
  options.standard_filesystems = {
    tmpfs_size = lib.mkOption {
      type = lib.types.str;
      default = "4G";
    };
    partuuids = {
      ${key_pool} = lib.mkOption {
        type = lib.types.str;
      };
      swap = lib.mkOption {
        type = lib.types.str;
      };
      boot = lib.mkOption {
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
          "zfs-import-${root_pool}.service"
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
          zpool import ${key_pool}
          zpool scrub -w ${key_pool}
          mkdir /zfskeys
          mount -t zfs -o ro ${key_pool} /zfskeys

          echo "Loading ZFS pools and keys"
          zpool import -a
          zfs load-key -a

          echo "Unloading bootstrap keys"
          umount /zfskeys
          zpool export ${key_pool}
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
        device = "${root_pool}/enc/snap/root";
        fsType = "zfs";
        neededForBoot = true;
      };

      "/home/keith" = {
        device = "${root_pool}/enc/snap/home/keith";
        fsType = "zfs";
      };

      "/nix" = {
        device = "${root_pool}/enc/snap/nix";
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
    systemd.services.writeBootRecoveryScript = {
      script = ''
        tee /boot/mount_recovery.sh <<EOF
        if (( \$EUID != 0 )); then
            echo "Not root"
            exit
        fi
        set -e
        set -x

        # Unlock the LUKS volume containing ZFS keys.
        systemd-cryptsetup attach ${key_pool} '/dev/disk/by-partuuid/${cfg.partuuids.zfskeys}'
        zpool import ${key_pool}
        # Make sure the partition is healthy.
        zpool scrub -w ${key_pool}
        mkdir -p /zfskeys
        mount -t zfs -o ro ${key_pool} /zfskeys

        # Import all the other pools.
        zpool import -a -f
        zfs load-key -a

        # Configure everything on /os
        mkdir -p /os
        mount -t zfs ${root_pool}/enc/snap/root /os
        mount -t zfs ${root_pool}/enc/snap/home/keith /os/home/keith
        mount -t zfs ${root_pool}/enc/snap/nix /os/nix
        mount '/dev/disk/by-partuuid/${cfg.partuuids.boot}' /os/boot
        echo 'System mounted on /os'
        EOF

        tee /boot/unmount_recovery.sh <<EOF
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
        systemd-cryptsetup detach ${key_pool}
        rmdir /os /zfskeys
        EOF

        chmod u+x /boot/mount_recovery.sh /boot/unmount_recovery.sh
      '';
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
      };
    };
  };
}
