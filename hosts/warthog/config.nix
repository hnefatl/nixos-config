{ pkgs, impermanence, ... }:
{
  imports = [
    ./boot.nix
    ./impermanence.nix
    ./ssh.nix
    ../../os/users/keith.nix
    ./services.nix
  ];

  nix = {
    package = pkgs.nixVersions.stable;
    optimise = {
      automatic = true;
      dates = [ "Sat *-*-* 09:00:00" ];
    };
    gc = {
      automatic = true;
      dates = "Sat *-*-* 08:00:00";
      options = "--delete-older-than 30d";
    };
    settings = {
      auto-optimise-store = true;
      # Required by `nh` at least.
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.nvidia.acceptLicense = true;
  hardware.nvidia = {
    datacenter.enable = true;
    nvidiaPersistenced = true;
    powerManagement.enable = true;
    open = true;
  };

  systemd.network = {
    enable = true;
    networks."10-lan" = {
      matchConfig.Name = "eno1";
      address = [
        "10.20.1.3/16"
      ];
      routes = [
        { Gateway = "10.20.0.1"; }
      ];
      linkConfig.RequiredForOnline = "routable";
    };
  };
  networking = {
    hostName = "warthog";
    hostId = "d818a96b";
    useDHCP = false;
  };

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  # TTY config
  console.keyMap = "uk";

  environment.systemPackages = with pkgs; [
    wget
    ncdu
    htop
    acpi
    sysstat
  ];

  programs.git = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.nh.enable = true;

  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    interactiveShellInit = ''
      # Necessary because vim keybindings disable this binding?
      bindkey '^R' history-incremental-search-backward
      # Prevents trying to overwrite the impermanence-symlinked history file.
      unsetopt HIST_SAVE_BY_COPY
    '';
    #plugins = [
    #  {
    #    name = "vi-mode";
    #    src = pkgs.zsh-vi-mode;
    #    file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
    #  }
    #];
    shellAliases = {
      c = "clear";
      nso = "nh os switch /etc/nixos";
    };
  };

  system.stateVersion = "25.05";
}
