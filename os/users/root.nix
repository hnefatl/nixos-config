{ config, lib, pkgs, ... }:

{
  users.users.root = {
    uid = 0;
    # Generate with `mkpasswd > secrets/root_password`
    hashedPasswordFile = "/etc/nixos/secrets/root_password";
  };
}

