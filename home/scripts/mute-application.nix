{ pkgs, lib, ... }:

pkgs.writeShellApplication {
  name = "mute-application";
  text = lib.readFile ./mute-application.sh;

  runtimeInputs = with pkgs; [
    jq
    pulseaudio
    # Also depends on swaymsg, but if that's not installed then this script needs major changes anyway.
  ];
}