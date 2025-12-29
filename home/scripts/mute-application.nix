{ pkgs, lib, ... }:

pkgs.writeShellApplication {
  name = "mute-application";
  text = lib.readFile ./mute-application.sh;

  runtimeInputs = with pkgs; [
    pulseaudio
    jq
    libnotify
    # Also depends on swaymsg, but if that's not installed then this script needs major changes anyway.
  ];
}
