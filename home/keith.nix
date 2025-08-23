{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./swayidle.nix
    ./unfree.nix
    ./feh.nix
    ./mpv.nix
    ./vscode.nix
    ./ssh.nix
    ./fuzzel.nix
  ];

  home = rec {
    username = "keith";
    homeDirectory = "/home/${config.home.username}";

    packages =
      with pkgs;
      [
        discord
        spotify
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

  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    extraOptions = lib.mkIf (config.machine_config.instance == "desktop") [ "--unsupported-gpu" ];
    wrapperFeatures.gtk = true;
    config = rec {
      terminal = "kitty";
      defaultWorkspace = "workspace number 1";
      # Set the primary monitor in X11 for xwayland apps. Prevents e.g. games defaulting to wrong screen.
      startup = [
        {
          command = "${lib.getExe pkgs.xorg.xrandr} --output ${config.machine_config.primaryMonitor} --primary";
          always = true;
        }
      ];

      # Cycle around containers in the same workspace.
      # TODO: Still need something like i3-cycle to define "horizontal-only" workspace wrapping (or like tabbed-workspace-direction-only).
      # focus.wrapping = "workspace";

      fonts = {
        names = [ "Noto Sans" ];
        style = "Mono";
        size = "10";
      };

      input = {
        "type:keyboard" = {
          xkb_layout = "gb";
          xkb_options = "caps:escape";
          repeat_delay = "200";
          repeat_rate = "58";
          xkb_numlock = "true";
        };
        "type:touchpad" = {
          tap = "enabled";
          # Disable-while-typing
          dwt = "enabled";
        };
      };
      output."*".adaptive_sync = "true";
      # Desktop screens
      output."LG Electronics LG ULTRAGEAR 102MAMBHL915" = {
        position = "0,0";
      };
      output."Samsung Electric Company LF24T35 H4LRC06671" = {
        position = "2560,0";
        transform = "90";
      };
      # Desk screen
      output."Dell Inc. DELL P2720DC 81WTK0131RMS" = {
        position = "-320,-1440";
      };

      window = {
        border = 2;
        titlebar = false;
        hideEdgeBorders = "--i3 smart";
      };
      gaps.smartBorders = "on";
      focus = {
        mouseWarping = "container";
        followMouse = false;
      };

      bars = [
        {
          position = "top";
          trayOutput = "primary";
          statusCommand = "${pkgs.i3blocks}/bin/i3blocks";
        }
      ];

      keybindings = (import ./sway-keybindings.nix { inherit pkgs lib; });
    };
    extraConfig = ''
      # If a game is focused, disable idle
      for_window [class="steam_app*"] inhibit_idle focus
    '';
  };

  # Configure swaylock for all invocations (e.g. manual, lid-close, hibernate, ...).
  programs.swaylock = {
    enable = true;
    # Supports extra features
    package = pkgs.swaylock-effects;
    settings = {
      show-failed-attempts = true;
      show-keyboard-layout = true;
      indicator-caps-lock = true;
      indicator-idle-visible = true;
      color = "101010";
      # Extra settings from the -effects fork.
      clock = true;
      timestr = "%H:%M"; # HH:MM
      datestr = "%F"; # YYYY-MM-DD
      indicator = true;
    };
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

  systemd.user = {
    enable = true;

    services = {
      discord = lib.mkIf (!config.machine_config.isWork) {
        Unit = {
          Description = "Start discord on login.";
          # Wait for network to avoid "reconnecting" on startup.
          # TODO: doesn't seem to work, maybe network service isn't available in user mode?
          After = [ "network-online.service" ];
          Wants = [ "graphical-session.target" ];
        };
        Service = {
          Type = "exec";
          RemainAfterExit = true;
          ExecStart = "${pkgs.discord}/bin/discord --start-minimized";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };

  home.stateVersion = "24.11";
}
