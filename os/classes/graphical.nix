# "Graphical" machines - not headless, expected to have some "normal" desktop environment.

{ config, pkgs, ... }:
{
  imports = [
    ../modules/hibernate.nix
    ../modules/greetd.nix
    ../modules/audio.nix
  ];

  environment.systemPackages = with pkgs; [
    dmenu
    gparted
    pulseaudio
    networkmanagerapplet
    scrot
    xclip
    arandr
    pavucontrol
    vlc
    xorg.xev
    gimp
    brightnessctl
    yubioath-flutter
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.gnome.gnome-keyring.enable = true;

  services.blueman.enable = config.hardware.bluetooth.enable;
}
