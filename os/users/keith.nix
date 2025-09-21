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
    hashedPasswordFile = "/run/secrets-for-users/user_passwords/keith";
    extraGroups = [
      "wheel"
      "video"
      "gamemode"
    ];
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = lib.mkIf (config.machine_config.instance == "desktop") [
      # Personal laptop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ46ZX6zJQrMOdffEZqJk5bbgZpTnaExEprMDS9aQUpa keith@laptop"
      # Corp laptop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFwVu5wURjrYYBrXhuX1L/Bdi0fliXs1ldSI16QEHcjd kcollister@kcollister"
    ];
  };
}
