# Use e.g. `nixos-option services.fprintd.enable` to query the value of the current config.

{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./users/users.nix
      ./graphics/graphics.nix
      ./hibernate.nix
      # TODO: figure out how to make vpn reconnect cleanly
      #./wireguard.nix
      ./fingerprint.nix
      ./bluetooth.nix
      ./greetd.nix
      ./gaming.nix
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
    # Font details: https://files.ax86.net/terminus-ttf/README.Terminus.txt
    # 1 is codepage, 16 is size, n is normal style.
    font = "${pkgs.terminus_font}/share/consolefonts/ter-116n.psf.gz";
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

  # Useful for debugging available fonts.
  fonts.fontDir.enable = true;

  services.tlp.enable = config.machine_config.formFactor == "laptop";

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  # If using another lock program, will need to update this PAM service name.
  security.pam.services.swaylock = {
    # Necessary to allow lockscreens
    text = ''
      auth include login
    '';
  };

  # DO NOT CHANGE: original NixOS version, for backcompat decisions.
  system.stateVersion = "24.11"; # Did you read the comment?
}

