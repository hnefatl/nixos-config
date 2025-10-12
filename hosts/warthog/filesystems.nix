{ lib, ... }:
let
  poolMounts = {
    "/pool/services" = "zfast/enc/snap/services";
    "/pool/services/docker_configs/vintagestory" = "zfast/enc/snap/services/vintagestory";
    "/pool/backup" = "zslow/enc/snap/backup";
    "/pool/old_disks" = "zslow/enc/old_disks";
    "/pool/jellyfin" = "zfast/enc/jellyfin";
    "/pool/plex" = "zfast/enc/plex";
    "/pool/immich" = "zslow/enc/immich";
    "/pool/transfer" = "zslow/enc/transfer";
    "/pool/media" = "zslow/enc/media";
  };
  poolFilesystem = mount: dataset: {
    device = dataset;
    fsType = "zfs";
    # Pool filesystems aren't critical to boot, don't drop to an emergency shell if I make a typo when renaming one.
    # TODO: make a `pool-fs.target` systemd entity for tracking pool mounts, like `local-fs` tracks root mounts (and maybe pool mounts but nofail?).
    # Should allow for blocking services on their relevant filesystem?
    options = [ "nofail" ];
  };
  poolFilesystems = lib.mapAttrs poolFilesystem poolMounts;
in
{
  imports = [ ../standard-filesystems.nix ];

  standard_filesystems.partuuids = {
    zfskeys = "967c71b3-c11d-431b-a3f6-cf60da272015";
    swap = "98f0a952-5e59-486b-aa38-a43e384bc19c";
    boot = "2fd6326a-3cbb-4cbe-ba46-59b72f80094c";
  };

  fileSystems = poolFilesystems;
}
