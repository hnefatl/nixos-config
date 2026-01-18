{ pkgs, lib, ... }:

pkgs.writeShellApplication {
  name = "camera-backup";
  text = lib.readFile ./camera-backup.sh;

  runtimeInputs = with pkgs; [
    util-linux
    sudo
    rsync
    libnotify
  ];
}