{ pkgs, lib, ... }:

pkgs.writeShellApplication {
  name = "camera-mount-and-store";
  text = lib.readFile ./camera-mount-and-store.sh;

  runtimeInputs = with pkgs; [
    util-linux
    sudo
    rsync
    libnotify
  ];
}