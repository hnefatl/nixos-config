{ pkgs, ... }:
{
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
}