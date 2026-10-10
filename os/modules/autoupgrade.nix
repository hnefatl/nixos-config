{ config, lib, ... }:
{
  nixos-autoupgrade = {
    enable = true;
    when =
      if config.machine_config.instance == "warthog" then
        # Weekly at 1am on Saturdays
        "00 01 * * Sat"
      else
        # Daily at 1am
        "00 01 * * *";

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
