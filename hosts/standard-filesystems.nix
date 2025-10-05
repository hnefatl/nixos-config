# Standardised filesystem layout.
# Assumes standardised naming documented in /docs/disk_security.md.

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
          "zfs-import-zroot.service"
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
          zpool import zfskeys
          zpool scrub -w zfskeys
          mkdir /zfskeys
          mount -t zfs -o ro zfskeys /zfskeys

          echo "Loading ZFS pools and keys"
          zpool import -a
          zfs load-key -a

          echo "Unloading bootstrap keys"
          umount /zfskeys
          zpool export zfskeys
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
        device = "zroot/enc/snap/root";
        fsType = "zfs";
        neededForBoot = true;
      };

      "/home/keith" = {
        device = "zroot/enc/snap/home/keith";
        fsType = "zfs";
      };

      "/nix" = {
        device = "zroot/enc/snap/nix";
        fsType = "zfs";
        options = [ "noatime" ];
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
  };
}
