{ config, pkgs, ... }:
{
  sops.secrets."user_passwords/root".neededForUsers = true;

  users.users.root = {
    uid = 0;
    hashedPasswordFile = config.sops.secrets."user_passwords/root".path;
    shell = pkgs.zsh;
  };
}
