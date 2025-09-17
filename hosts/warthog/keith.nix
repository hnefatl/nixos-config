{ pkgs, ... }:
{
  users.mutableUsers = false;
  users.users.keith = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = "/persist/secrets/keith_password";

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ46ZX6zJQrMOdffEZqJk5bbgZpTnaExEprMDS9aQUpa keith@laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFwVu5wURjrYYBrXhuX1L/Bdi0fliXs1ldSI16QEHcjd kcollister@kcollister"
    ];
  };
}
