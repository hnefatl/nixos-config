{ config, lib, pkgs, ... }:

{
  # Immutable user configs.
  users.mutableUsers = false;
  users.users.root = {
    uid = 0;
    hashedPassword = "**REDACTED**";
  };
  users.users.keith = {
    isNormalUser = true;
    hashedPassword = "**REDACTED**";
    extraGroups = [ "wheel" ]; # Enable `sudo`
  };
}

