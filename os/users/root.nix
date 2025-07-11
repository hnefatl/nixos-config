{ config, lib, pkgs, ... }:

{
  users.users.root = {
    uid = 0;
    hashedPassword = "**REDACTED**";
  };
}

