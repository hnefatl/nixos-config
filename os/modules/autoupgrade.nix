{ config, ... }:
{
  nixos-autoupgrade = {
    when =
      if config.machine_config.instance == "warthog" then
        # Weekly at 1am on Saturdays
        "00 01 * * 6"
      else
        # Daily at 1am
        "00 01 * * *";

    args = rec {
      os-flake-dir = "/etc/nixos/os";
      home-flake-dir = "/etc/nixos/home";
      home-user = "keith";
      update-inputs = "nixpkgs";
      from-email = "hnefatl+infrastructure@gmail.com";
      to-email = from-email;
    };
  };

  # Needed since the upgrader runs as root, and these dirs aren't owned by root.
  programs.git.config.safe.directory = [
    "/etc/nixos"
    "/etc/nixos/secrets"
  ];
}
