{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./boot.nix
      ./users.nix
      ./graphics.nix
    ];

  networking.hostName = "PC";
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  # TTY config
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    xkb = {
      layout = "gb";
      options = "caps:escape";
    };

    autoRepeatDelay = 200;
    autoRepeatInterval = 17;

    windowManager.i3.enable = true;
  };
  services.displayManager.autoLogin = {
    enable = true;
    user = "keith";
  };

  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    # Pulseaudio compatability layer.
    pulse.enable = true;
  };

  programs.firefox.enable = true;

  # Allowlist for nonfree packages.
  nixpkgs.config.allowUnfreePredicate = p: builtins.elem (lib.getName p) [
    "spotify"
    "discord"

    "steam"
    "steam-original"
    "steam-unwrapped"
    "steam-run"

    "nvidia-x11"
    "nvidia-settings"
    "nvidia-persistenced"
  ];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    ncdu
    htop
    sysstat
    dmenu
    gparted
    terminator
    pulseaudio
    i3blocks
    i3lock
    arandr
    ntfs3g
    spotify
    playerctl
    pavucontrol
    discord
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.git.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Allow Spotify to discover Google Cast devices.
  networking.firewall.allowedUDPPorts = [ 5333 ];
  services.avahi.enable = true;

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
    ];
    fontDir.enable = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["Noto Serif"];
        sansSerif = ["Noto Sans"];
        monospace = ["Noto Sans Mono"];
        emoji = ["Noto Color Emoji"];
      };
    };
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Copy the NixOS configuration file to /run/current-system/configuration.nix.
  system.copySystemConfiguration = true;

  # DO NOT CHANGE: original NixOS version, for backcompat decisions.
  system.stateVersion = "24.11"; # Did you read the comment?
}

