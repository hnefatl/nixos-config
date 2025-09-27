{
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/EC4A-F86F";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  fileSystems."/" = {
    device = "zpoolroot/ephemeral/root";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "zpoolroot/nix";
    fsType = "zfs";
  };

  fileSystems."/persist" = {
    device = "zpoolroot/persist";
    fsType = "zfs";
    neededForBoot = true;
  };
  # Required so that impermanence has the filesystem available for setting user passwords:
  # https://github.com/Mic92/sops-nix?tab=readme-ov-file#setting-a-users-password
  fileSystems."/etc/nixos".neededForBoot = true;

  fileSystems."/pool/services" = {
    device = "zfast/enc/snap/services";
    fsType = "zfs";
  };

  fileSystems."/pool/services/docker_configs/vintagestory" = {
    device = "zfast/enc/snap/services/vintagestory";
    fsType = "zfs";
  };

  fileSystems."/pool/backup" = {
    device = "zslow/enc/snap/backup";
    fsType = "zfs";
  };

  fileSystems."/pool/backup/devices" = {
    device = "zslow/enc/snap/backup/devices";
    fsType = "zfs";
  };
  fileSystems."/pool/backup/devices/desktop" = {
    device = "zslow/enc/snap/backup/devices/desktop";
    fsType = "zfs";
  };
  fileSystems."/pool/backup/devices/laptop" = {
    device = "zslow/enc/snap/backup/devices/laptop";
    fsType = "zfs";
  };

  fileSystems."/pool/old_disks" = {
    device = "zslow/enc/old_disks";
    fsType = "zfs";
  };

  fileSystems."/pool/jellyfin" = {
    device = "zfast/enc/jellyfin";
    fsType = "zfs";
  };

  fileSystems."/pool/plex" = {
    device = "zfast/enc/plex";
    fsType = "zfs";
  };

  fileSystems."/pool/immich" = {
    device = "zslow/enc/immich";
    fsType = "zfs";
  };

  fileSystems."/pool/transfer" = {
    device = "zslow/enc/transfer";
    fsType = "zfs";
  };

  fileSystems."/pool/media" = {
    device = "zslow/enc/media";
    fsType = "zfs";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/71d49f75-93a1-44f6-ab19-4a31ffc16508"; }
  ];
}
