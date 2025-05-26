{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./boot.nix
      ./users.nix
      ./graphics.nix
      ./hibernate.nix
    ];

  networking.hostName = "desktop";
  networking.networkmanager.enable = true;
  # Don't wait for network startup, for faster boots: `systemd-analyze`
  # https://old.reddit.com/r/NixOS/comments/vdz86j/how_to_remove_boot_dependency_on_network_for_a
  systemd = {
    services.NetworkManager-wait-online.wantedBy = pkgs.lib.mkForce [];  # Normally ["network-online.target"]
  };

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
      # cat $(nix-build --no-out-link '<nixpkgs>' -A xkeyboard_config)/etc/X11/xkb/rules/base.lst | less
      options = "caps:hyper";
    };

    autoRepeatDelay = 200;
    autoRepeatInterval = 17;

    windowManager.i3 = {
      enable = true;
      extraSessionCommands = ''
	# Desktop background colour
        xsetroot -solid "#333333"
      '';
    };

    # Configure initial monitor layout.
    xrandrHeads = [{
      output = "DP-0";
      primary = true;
      monitorConfig = ''
        Option "Position" "0 331"
      '';
    } {
      output = "HDMI-0";
      monitorConfig = ''
        Option "Rotate" "right"
      '';
    }];
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
  programs.zsh.enable = true;

  # Allowlist for nonfree packages.
  nixpkgs.config.allowUnfreePredicate = p: builtins.elem (lib.getName p) [
    "spotify"
    "discord"

    "steam"
    "steam-original"
    "steam-unwrapped"
    "steam-run"

    "vscode"
    "vscode-with-extensions"
    "vscode-extension-ms-vscode-remote-remote-ssh"

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
    pciutils
    flashrom
    unzip
    terminator
    pulseaudio
    i3blocks
    i3lock
    scrot
    xclip
    arandr
    ntfs3g
    playerctl
    pavucontrol
    vlc
    xorg.xev
    gimp
    (callPackage ./vscode.nix {})
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

  # Only very few proprietary drivers here but nice when it works :)
  services.fwupd.enable = true;

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  programs.ssh.startAgent = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Allow Spotify to discover Google Cast devices.
  networking.firewall = {
    allowedUDPPorts = [ 5333 ];
    allowedTCPPorts = [ 22 ];
  };
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

  # Copy the NixOS configuration file to /run/current-system/configuration.nix.
  system.copySystemConfiguration = true;

  # DO NOT CHANGE: original NixOS version, for backcompat decisions.
  system.stateVersion = "24.11"; # Did you read the comment?
}

