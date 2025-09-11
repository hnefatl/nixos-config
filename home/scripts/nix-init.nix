{ pkgs, lib, ... }:

pkgs.writeShellApplication {
  name = "nix-init";
  text = lib.readFile ./nix-init.sh;
}
