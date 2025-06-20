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

  users.users."shutdown-helper" = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      # HA for shutdown
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILzavfVQ9+CH89XqFLwIErHTExg4PoZmAON3D8zkJ9KE root@core-ssh"
    ];
  };
}

