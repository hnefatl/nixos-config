{ pkgs, lib, ... }:

pkgs.writeShellApplication {
  name = "screencap";
  text = lib.readFile ./screencap.sh;

  runtimeInputs = with pkgs; [
    sway-contrib.grimshot
    slurp
    fuzzel
    wf-recorder
    libnotify
    procps
  ];
}