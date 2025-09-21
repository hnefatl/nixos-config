{
  pkgs,
  lib,
  config,
  ...
}:
{
  boot.supportedFilesystems.zfs = true;
  # TODO: move this into host section? should be unique per-machine
  # `head -c4 /dev/urandom | od -A none -t x4`
  networking.hostId = "35e976f0";
  # https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/index.html
  boot.zfs.forceImportRoot = false;

  services.zfs = {
    autoSnapshot = {
      # Also requires `com.sun:auto-snapshot` on relevant datasets.
      enable = true;
      # UTC avoids issues with daylight savings.
      flags = "-k -p --utc";
    };
    autoScrub = {
      enable = true;
      # TODO
      pools = [ ];
      interval = "weekly";
    };
  };

  # TODO: syncoid/sanoid/...?
}
