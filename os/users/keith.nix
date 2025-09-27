{
  config,
  pkgs,
  lib,
  ...
}:

{
  sops.secrets."user_passwords/keith".neededForUsers = true;

  users.users.keith = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets."user_passwords/keith".path;
    extraGroups = [
      "wheel"
      "video"
    ]
    ++ lib.optionals config.programs.gamemode.enable [ "gamemode" ];

    shell = pkgs.zsh;

    openssh.authorizedKeys.keys =
      let
        keys = import ../../common/ssh_keys.nix;
      in
      [
        keys.keith.laptop
        keys.keith.desktop
        keys.keith.corp-laptop
      ];
  };
}
