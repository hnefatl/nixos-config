{ pkgs, lib, ... }:

pkgs.writeShellApplication {
  name = "dim-screen";
  text = lib.readFile ./dim-screen.sh;

  runtimeInputs = with pkgs; [
    brightnessctl
    bc
  ];
}
