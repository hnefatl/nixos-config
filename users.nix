{ lib, pkgs, ... }:

{
  imports = [
    # Comes from nix-channel defn
    <home-manager/nixos>
    ./keith.nix
  ];

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  # Immutable user configs.
  users.mutableUsers = false;
  users.users.root = {
    uid = 0;
    hashedPassword = "**REDACTED**";
  };

  # Allow these users to edit the nixos config files.
  users.groups.nixos.members = [ "keith" "root" ];
}

