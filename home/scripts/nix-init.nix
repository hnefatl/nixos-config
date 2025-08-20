{ pkgs, ... }:

pkgs.writeShellApplication {
  name = "nix-init";
  text = ./nix-init.sh;
}

