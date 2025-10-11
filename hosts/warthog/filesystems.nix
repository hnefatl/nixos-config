{
  imports = [ ../standard-filesystems.nix ];

  standard_filesystems.partuuids = {
    zfskeys = "967c71b3-c11d-431b-a3f6-cf60da272015";
    swap = "98f0a952-5e59-486b-aa38-a43e384bc19c";
    boot = "2fd6326a-3cbb-4cbe-ba46-59b72f80094c";
  };

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
}
