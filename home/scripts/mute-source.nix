{ pkgs, lib, ... }:

pkgs.writeShellApplication {
  name = "mute-source";
  text = lib.readFile ./mute-source.sh;

  runtimeInputs = with pkgs; [
    pulseaudio
    jq
    libnotify
  ];
}
