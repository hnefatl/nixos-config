{ config, lib, ... }:
{
  # TODO: cron won't run on next boot if it misses a timer, so 1am upgrades are unlikely to happen.
  # Systemd service with persistent timer seemed to get restarted during upgrade, breaking the update.
  # Need some other low-tech solution? Background daemon watching a "last updated" file?
  nixos-autoupgrade = {
    enable = true;
    when =
      if config.machine_config.instance == "warthog" then
        # Weekly at 1am on Saturdays
        "00 01 * * Sat"
      else
        # Daily at midnight
        "00 00 * * *";

    args = rec {
      os-flake-dir = "/etc/nixos/os";
      # No home-manager config on warthog, due to impermanence.
      home-flake-dir = lib.mkIf (config.machine_config.hostname != "warthog") "/etc/nixos/home";
      home-user = "keith";
      update-inputs = "nixpkgs nixpkgs-unstable";
      from-email = "hnefatl+autoupgrader@gmail.com";
      to-email = from-email;
    };
  };

  # Needed since the upgrader runs as root, and these dirs aren't owned by root.
  programs.git.config.safe.directory = [
    "/etc/nixos"
    "/etc/nixos/secrets"
  ];
}
