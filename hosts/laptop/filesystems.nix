{
  boot.initrd = {
    luks.devices = {
      "zfskeys".device = "/dev/disk/by-partuuid/a5647497-3434-454a-bafc-eecb3f96412d";
      "swap".device = "/dev/disk/by-partuuid/7ebfa198-972a-49ee-8f8c-e33c01271b8a";
    };

    systemd.services.zfskeybootstrap = {
      wantedBy = [ "initrd.target" ];
      after = [ "cryptsetup.target" ];
      # Finish loading keys to the pools before starting the ZFS mounts
      before = [ "zfs-import-zroot.service" "sysroot.mount" ];
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
      device = "/dev/disk/by-partuuid/1fd3542b-4c9d-4355-ba94-2336252adfa1";
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
        "size=4G"
        "noatime"
      ];
    };
  };
}
