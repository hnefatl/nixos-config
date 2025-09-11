{
  config,
  pkgs,
  lib,
  ...
}:

{
  users.users.keith = {
    isNormalUser = true;
    # Generate with `mkpasswd > secrets/keith_password`
    hashedPasswordFile = "/etc/nixos/secrets/keith_password";
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
