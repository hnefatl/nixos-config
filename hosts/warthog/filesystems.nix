{
  imports = [ ../standard-filesystems.nix ];

  standard_filesystems.partuuids = {
    zfskeys = "967c71b3-c11d-431b-a3f6-cf60da272015";
    swap = "98f0a952-5e59-486b-aa38-a43e384bc19c";
    boot = "2fd6326a-3cbb-4cbe-ba46-59b72f80094c";
  };

  # TODO: make a `pool-fs.target` systemd entity for tracking pool mounts.
  fileSystems."/pool/services" = {
    device = "zfast/enc/snap/services";
    fsType = "zfs";
    options = [ "nofail" ];
  };

  fileSystems."/pool/services/docker_configs/vintagestory" = {
    device = "zfast/enc/snap/services/vintagestory";
    fsType = "zfs";
    options = [ "nofail" ];
  };

  fileSystems."/pool/backup" = {
    device = "zslow/enc/snap/backup";
    fsType = "zfs";
    options = [ "nofail" ];
  };

  fileSystems."/pool/old_disks" = {
    device = "zslow/enc/old_disks";
    fsType = "zfs";
    options = [ "nofail" ];
  };

  fileSystems."/pool/jellyfin" = {
    device = "zfast/enc/jellyfin";
    fsType = "zfs";
    options = [ "nofail" ];
  };

  fileSystems."/pool/plex" = {
    device = "zfast/enc/plex";
    fsType = "zfs";
    options = [ "nofail" ];
  };

  fileSystems."/pool/immich" = {
    device = "zslow/enc/immich";
    fsType = "zfs";
    options = [ "nofail" ];
  };

  fileSystems."/pool/transfer" = {
    device = "zslow/enc/transfer";
    fsType = "zfs";
    options = [ "nofail" ];
  };

  fileSystems."/pool/media" = {
    device = "zslow/enc/media";
    fsType = "zfs";
    options = [ "nofail" ];
  };
}
