{ config, ... }:
{
  imports = [
    # Any machine running ZFS is also serious enough to care about these.
    ./zed.nix
    ../smartd.nix
  ];

  boot = {
    supportedFilesystems.zfs = true;
    # https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/index.html
    zfs.forceImportRoot = false;
  };
  networking.hostId = config.machine_config.hostid;

  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "weekly";
    };
  };

  # Automatic snapshots.
  # TODO: finish moving old snapshotted things (`zfs list -o name,com.sun:auto-snapshot`) to opt-in per device.
  services.sanoid = {
    enable = true;
    interval = "hourly";
    extraArgs = [ "verbose" ];

    datasets."zroot/enc/snap" = {
      # Use `zfs snapshot -r` for an atomic snapshot of the whole tree. This lets us transfer the
      # whole snapshot encrypted to an untrusted host for backups.
      recursive = "zfs";
      autosnap = true;

      # Local machine snapshots are high fidelity for a few days then downsampled. No long-term
      # snapshots are kept.
      autoprune = true;
      hourly = 48;
      daily = 28;
      weekly = 8;
      monthly = 0;
      yearly = 0;
    };
  };

  # TODO: rust wrapper around `man zpool events` that sends discord notifications on events?
  # TODO: MOTD-style banner on server login?
}
