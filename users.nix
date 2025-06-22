{ config, lib, pkgs, ... }:

let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;
in
{
  imports = [
    (import "${home-manager}/nixos")
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

  users.users."shutdown-helper" = lib.mkIf (config.machine_config.instance == "desktop") {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      # HA for shutdown
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILzavfVQ9+CH89XqFLwIErHTExg4PoZmAON3D8zkJ9KE root@core-ssh"
    ];
  };
  security.polkit = lib.mkIf (config.machine_config.instance == "desktop") {
    # Allow remote poweroff.
    extraConfig = ''
      polkit.addRule(function(action, subject) {
       if (subject.user != "shutdown-helper") return polkit.Result.NOT_HANDLED;
        if (action.id == "org.freedesktop.login1.power-off" ||
            action.id == "org.freedesktop.login1.power-off-multiple-sessions") {
          return polkit.Result.YES;
        }
        return polkit.Result.NOT_HANDLED;
      });
    '';
  };
}

