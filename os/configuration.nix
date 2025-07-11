# Use e.g. `nixos-option services.fprintd.enable` to query the value of the current config.

{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./boot.nix
      ./users/users.nix
      ./graphics/graphics.nix
      ./hibernate.nix
      ./wireguard.nix
      ./fingerprint.nix
      ./bluetooth.nix
    ];

  nix = {
    package = pkgs.nixVersions.stable;
    optimise = {
      automatic = true;
      dates = ["Sat *-*-* 09:00:00"];
    };
    gc = {
      automatic = true;
      dates = "Sat *-*-* 08:00:00";
      options = "--delete-older-than 30d";
    };
    settings = {
      auto-optimise-store = true;
      # Required by `nh` at least.
      experimental-features = ["nix-command" "flakes"];
    };
  };

  networking.hostName = config.machine_config.hostname;
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
    keyMap = "uk";
    font = "Lat2-Terminus16";
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

  services.autorandr.enable = true;

  programs.firefox.enable = true;
  programs.zsh.enable = true;

  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    ncdu
    htop
    acpi
    sysstat
    fatrace
    python3
    dmenu
    gparted
    pciutils
    flashrom
    unzip
    pulseaudio
    networkmanagerapplet
    scrot
    xclip
    arandr
    playerctl
    pavucontrol
    vlc
    xorg.xev
    gimp
    p7zip
    brightnessctl
    nix-inspect
    jujutsu
    speedtest-cli
    yubioath-flutter
    (callPackage ./vscode.nix {})
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.git.enable = true;

  programs.nh.enable = true;

  programs.steam = let
    isDesktop = config.machine_config.instance == "desktop";
  in {
    enable = true;
    # Only run the desktop as a "game provider server", to keep laptop slim.
    remotePlay.openFirewall = isDesktop; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = isDesktop; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = isDesktop; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  services.fwupd.enable = true;

  services.sunshine = lib.mkIf (config.machine_config.instance == "desktop") {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };

  programs.ssh.startAgent = true;
  services.openssh = lib.mkIf (config.machine_config.instance == "desktop") {
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

  services.greetd = {
    enable = true;
    settings = rec {
      # Login without prompting password when booted.
      initial_session = {
        command = "${pkgs.sway}/bin/sway" + (if config.machine_config.instance == "desktop" then " --unsupported-gpu" else "");
        user = "keith";
      };
      default_session = initial_session;
    };
  };

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # DO NOT CHANGE: original NixOS version, for backcompat decisions.
  system.stateVersion = "24.11"; # Did you read the comment?
}

