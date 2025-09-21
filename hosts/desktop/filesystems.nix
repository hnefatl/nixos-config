{
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5633-785D";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/44090b89-b355-4498-b272-4264d3d94ae8"; } ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/fb594a2d-ba40-4ed3-bc91-b1f53966b4e5";
    fsType = "btrfs";
    options = [ "subvol=root" ];
    neededForBoot = true;
  };

  fileSystems."/home/keith" = {
    device = "/dev/disk/by-uuid/fb594a2d-ba40-4ed3-bc91-b1f53966b4e5";
    fsType = "btrfs";
    options = [ "subvol=home/keith" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/fb594a2d-ba40-4ed3-bc91-b1f53966b4e5";
    fsType = "btrfs";
    options = [
      "subvol=nix"
      "noatime"
    ];
    # Maybe?
    neededForBoot = true;
  };

  fileSystems."/tmp" = {
    device = "none";
    fsType = "tmpfs";
    options = [
      "size=4G"
      "noatime"
    ];
  };

  fileSystems."/games" = {
    device = "zpoolgames/games";
    fsType = "zfs";
    options = [
      # Don't mount on boot, only when accessed.
      "noauto"
      "x-systemd.automount"
    ];
  };
}
