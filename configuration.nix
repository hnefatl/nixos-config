# Use e.g. `nixos-option services.fprintd.enable` to query the value of the current config.

{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./boot.nix
      ./users.nix
      ./graphics.nix
      ./wireguard.nix
      ./machine_config.nix
      #./hibernate.nix
    ];

  networking.hostName = "laptop";
  networking.networkmanager.enable = true;
  # Don't wait for network startup, for faster boots: `systemd-analyze`
  # https://old.reddit.com/r/NixOS/comments/vdz86j/how_to_remove_boot_dependency_on_network_for_a
  #systemd = {
  #  services.NetworkManager-wait-online.wantedBy = pkgs.lib.mkForce [];  # Normally ["network-online.target"]
  #};

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
  ];
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
  };

  services.fwupd.enable = true;

  programs.ssh.startAgent = true;

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
        command = "${pkgs.sway}/bin/sway";
        user = "keith";
      };
      default_session = initial_session;
    };
  };

  services.fprintd.enable = config.machine_config.hasFingerprintReader;
  systemd.services.fprintd = lib.mkIf config.machine_config.hasFingerprintReader {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };
  security.pam.services.swaylock = lib.mkIf config.machine_config.hasFingerprintReader {
    fprintAuth = true;
    # Allow passwords to unlock the lockscreen, not just fingerprint.
    text = ''
      auth sufficient pam_unix.so try_first_pass likeauth nullok
      auth sufficient pam_fprintd.so
      auth include login
    '';
  };

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # Copy the NixOS configuration file to /run/current-system/configuration.nix.
  system.copySystemConfiguration = true;

  # DO NOT CHANGE: original NixOS version, for backcompat decisions.
  system.stateVersion = "25.05"; # Did you read the comment?
}

