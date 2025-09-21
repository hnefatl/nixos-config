{ config, ... }:
{
  boot = {
    supportedFilesystems.zfs = true;
    # https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/index.html
    zfs.forceImportRoot = false;
  };
  networking.hostId = config.machine_config.hostid;

  services.zfs = {
    autoSnapshot = {
      # Also requires `com.sun:auto-snapshot` on relevant datasets.
      enable = true;
      # UTC avoids issues with daylight savings.
      flags = "-k -p --utc";
    };
    autoScrub = {
      enable = true;
      interval = "weekly";
    };
  };

  # TODO: syncoid?
}
