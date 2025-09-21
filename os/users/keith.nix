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

    openssh.authorizedKeys.keys = [
      # Personal laptop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ46ZX6zJQrMOdffEZqJk5bbgZpTnaExEprMDS9aQUpa keith@laptop"
      # Corp laptop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFwVu5wURjrYYBrXhuX1L/Bdi0fliXs1ldSI16QEHcjd kcollister@kcollister"
    ];
  };
}
