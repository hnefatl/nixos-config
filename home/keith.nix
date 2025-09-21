{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./unfree.nix
    ./sway/sway.nix
    ./sway/swaylock.nix
    ./sway/swayidle.nix
    ./feh.nix
    ./mpv.nix
    ./vscode.nix
    ./ssh.nix
    ./fuzzel.nix
    ./discord.nix
  ];

  home = rec {
    username = "keith";
    homeDirectory = "/home/${config.home.username}";

    packages =
      with pkgs;
      [
        spotify
        playerctl
        xidlehook
        i3blocks
        noto-fonts
        noto-fonts-color-emoji
        nerd-fonts.symbols-only
        wireguard-tools
        # Needed for e.g. blueman-applet icon.
        hicolor-icon-theme
        # File explorer
        xfce.thunar
        xfce.tumbler
        ffmpegthumbnailer

        # Utility scripts
        (pkgs.callPackage ./scripts/nix-init.nix { inherit pkgs; })
      ]
      ++ (
        # Remote desktop
        if config.machine_config.instance == "laptop" then [ moonlight-qt ] else [ ]
      );

    pointerCursor = {
      enable = true;
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 20;
      # Breaks build for home-manager?
      #sway.enable = true;
    };

    shellAliases = {
      c = "clear";
      cl = "clear ; ls";
      nso = "nh os switch /etc/nixos/os";
      nsh = "nh home switch /etc/nixos/home";
      alert = "echo -e '\\a'";
    };
  };

  programs.home-manager.enable = true;
  programs.nh.enable = true;

  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "Noto Sans Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 10000;
      ignoreDups = true;
      # Don't update a terminal with the latest commands from other terminals.
      # Causes confusing "up arrow is the last command run in any zsh, not this zsh".
      share = false;
    };
    initContent = ''
      # Necessary because vim keybindings disable this binding?
      bindkey '^R' history-incremental-search-backward
    '';
    plugins = [
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
  };

  programs.kitty = lib.mkForce {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      font_family = "family = 'Noto Mono'";
      font_size = 12.0;
      cursor = "#aaaaaa";
      background = "#333333";
      foreground = "#ffffff";
      # Lose some kitty functionality for much better interop on remote machines w/out kitty installed.
      term = "xterm-256color";
    };
  };

  programs.neovim = {
    enable = true;
    extraConfig = ''
      syntax enable
      set autoindent
      set shiftwidth=4
      set tabstop=4
      set smarttab
      set expandtab
      set hlsearch
      set smartcase
      set relativenumber
      set number

      " Re-open at previous position in file: https://stackoverflow.com/a/774599
      if has("autocmd")
        au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
          \| exe "normal! g'\"" | endif
      endif
    '';
  };

  programs.obs-studio = lib.mkIf (config.machine_config.instance == "desktop") {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
    ];
  };
  programs.ranger.enable = true;
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    config = {
      # Lower verbosity output
      hide_env_diff = true;
    };
  };

  services.mako = {
    enable = true;
    settings = {
      actions = true;
      markup = true;
      default-timeout = 10000;
      border-size = 0;

      # Profile picture icons are big and distracting.
      "app-name=discord".icons = 0;
      # Similar for calendar. Maybe make smaller in the future since this also affects e.g. chat pfps?
      "app-name=\"Google Chrome\"".icons = 0;

      "urgency=low" = {
        background-color = "#222222";
        text-color = "#888888";
        default-timeout = 5000;
      };
      "urgency=normal" = {
        background-color = "#285577";
        text-color = "#ffffff";
        # Layer over fullscreen apps.
        layer = "overlay";
      };
      "urgency=critical" = {
        background-color = "#900000";
        text-color = "#ffffff";
        default-timeout = 0; # don't timeout
        layer = "overlay";
      };
    };
  };

  xdg.mimeApps.enable = true;
  xdg.portal = {
    enable = true;
    configPackages = [ pkgs.xdg-desktop-portal-wlr ];
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };

  systemd.user.enable = true;

  home.stateVersion = "24.11";
}
