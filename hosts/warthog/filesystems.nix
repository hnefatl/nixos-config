{ config, lib, ... }:
let
  poolMounts = {
    "/pool/services" = "zfast/enc/snap/services";
    "/pool/services/docker_configs/vintagestory" = "zfast/enc/freqsnap/vintagestory";
    "/pool/backup" = "zslow/enc/snap/backup";
    "/pool/old_disks" = "zslow/enc/old_disks";
    "/pool/jellyfin" = "zfast/enc/jellyfin";
    "/pool/plex" = "zfast/enc/plex";
    "/pool/immich" = "zslow/enc/immich";
    "/pool/transfer" = "zslow/enc/transfer";
    "/pool/media" = "zslow/enc/media";
    "/pool/attic" = "zslow/enc/attic";
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

  # Explicitly enumerate datasets to decrypt, to avoid trying to decrypt backup datasets that warthog doesn't have keys for.
  boot.zfs.requestEncryptionCredentials = [
    "zroot/enc"
    "zslow/enc"
    "zfast/enc"
  ];

  fileSystems = poolFilesystems;

  # TODO: this is pretty messy, partly because sanoid's not been very nix-ified, partly because
  # I should probably write a proper opinionated wrapper around it.
  services.sanoid = {
    # Run every 5mins, to reliably catch the 10min gameserver snapshots below.
    interval = lib.mkForce "*-*-* *:0/5:00";
    datasets =
      let
        # Copied from "zroot/enc/snap" configuration for now.
        standard = {
          recursive = "zfs";
          autosnap = true;
          autoprune = true;
          hourly = 48;
          daily = 28;
          weekly = 8;
          monthly = 0;
          yearly = 0;
        };
      in
      {
        # Take regular "standard" snapshots of the pool datasets.
        "zslow/enc/snap" = standard;
        "zfast/enc/snap" = standard;

        # Short-term high-frequency snapshots for e.g. game server files.
        # This can't be under `snap/...` because apparently sanoid skips recursive-in-recursive dataset configs, even if the settings are different :/
        # TODO: fix upstream?
        "zfast/enc/freqsnap" = {
          recursive = "zfs";
          autosnap = true;
          autoprune = true;
          # Every 10 mins for 4 hours.
          frequent_period = 10;
          frequently = 24;
          # Then downsample to a week of medium granularity.
          hourly = 72;
          daily = 7;
          weekly = 0;
          monthly = 0;
          yearly = 0;
        };
      };
  };
}
