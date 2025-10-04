{
  boot.initrd.luks.devices = {
    "zfskeys" = {
      device = "/dev/disk/by-partuuid/99a5dcba-1b59-49bc-8a51-5661d21d180b";
      # We need to make these available before the root filesystem mount, because
      # the root filesystem is encrypted using these keys.
      #
      # This mountpoint "vanishes" when stage 1 init completes, because it's mounted
      # into the initramfs rather than the "real" stage 2 root. Which is good, means
      # it's not hanging around.
      # The LUKS device remains opened though, which makes it clearer what the
      # partition is and allows mounting if new keys are needed.
      postOpenCommands = ''
        zpool import -f zfskeys
        mkdir /zfskeys
        mount -t zfs -o ro zfskeys /zfskeys
      '';
    };
    "swap".device = "/dev/disk/by-partuuid/6218dca0-7296-49c4-9f53-297fac74fbd7";
  };

  swapDevices = [ { device = "/dev/mapper/swap"; } ];

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-partuuid/88b38164-72bb-460c-83f6-218fb879aca8";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
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

    "/games" = {
      device = "zpoolgames/games";
      fsType = "zfs";
      options = [
        # Don't mount on boot, only when accessed.
        "noauto"
        "x-systemd.automount"
      ];
    };
  };
}
