# Disko options are kinda documented under https://github.com/nix-community/disko/tree/master/lib/types.
{
  disko.devices = {
    disk = {
      root = {
        type = "disk";
        #device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_1000GB_251318800751";
        device = "/dev/disk/by-id/nonexistent";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "10G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
              };
            };
            zfskeys = {
              size = "1G";
              content = {
                type = "luks";
                name = "zfskeys";
                content = {
                  type = "zfs";
                  pool = "zfskeys";
                };
              };
            };
            zroot = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
            swap = {
              size = "32G";
              content = {
                type = "luks";
                name = "swap";
                content = {
                  type = "swap";
                  discardPolicy = "both";
                  resumeDevice = true;
                };
              };
            };
          };
        };
      };
    };

    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          compression = "on";
        };
        datasets = {
          "enc" = {
            type = "zfs_fs";
            options = {
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "file:///zfskeys/zroot-enc.priv";
            };
          };
          "enc/snap".type = "zfs_fs";
          "enc/snap/home".type = "zfs_fs";
          "enc/snap/home/keith".type = "zfs_fs";
          "enc/snap/nix".type = "zfs_fs";
          "enc/snap/root".type = "zfs_fs";
        };
      };
    };
  };
}