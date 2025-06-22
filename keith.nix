{ config, pkgs, lib, ... }:

{
  users.users.keith = {
    isNormalUser = true;
    hashedPassword = "**REDACTED**";
    extraGroups = [ "wheel" "video" ];
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = lib.mkIf (config.machine_config.instance == "desktop") [
      # Laptop
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFwVu5wURjrYYBrXhuX1L/Bdi0fliXs1ldSI16QEHcjd kcollister@kcollister"
    ];
  };

  home-manager.users.keith = { pkgs, ... }: let
    catppuccin = builtins.fetchGit {
      url = "https://github.com/catppuccin/nix";
      # Recent pinned commit for stability.
      # Could use e.g.
      # `builtins.fetchTarball https://github.com/catppuccin/nix/archive/refs/tags/v1.2.1.tar.gz`
      # instead but there's no up-to-date stable release atm.
      rev = "6d571d2feebaaed62b0932b3a0eba4305a59be7f";
    };
  in {
    imports = [(import "${catppuccin}/modules/home-manager")];

    catppuccin.enable = true;
    catppuccin.flavor = "mocha";

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      history.size = 10000;
    };

    home = {
      packages = with pkgs; [
        discord
        spotify
        xidlehook
        i3blocks
        i3lock
      ];
      pointerCursor = {
        enable = true;
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
        size = 20;
        sway.enable = true;
      };
    };

    wayland.windowManager.sway = {
      enable = true;
      xwayland = true;
      extraOptions = lib.mkIf (config.machine_config.instance == "desktop") ["--unsupported-gpu"];
      wrapperFeatures.gtk = true;
      config = rec {
        terminal = "kitty";

        fonts = {
          names = ["Noto Sans"];
          style = "Mono";
          size = "10";
        };

        input = {
          "type:keyboard" = {
            xkb_layout = "gb";
            xkb_options = "caps:hyper";
            repeat_delay = "200";
            repeat_rate = "58";
            xkb_numlock = "true";
          };
          "type:touchpad" = {
            tap = "enabled";
          };
        };
        output."*".adaptive_sync = "true";

        window = {
          border = 2;
          hideEdgeBorders = "smart";
        };
        focus = {
          mouseWarping = "container";
          followMouse = false;
        };

        bars = [{
          position = "top";
          trayOutput = "primary";
          statusCommand = "${pkgs.i3blocks}/bin/i3blocks";
        }];

        keybindings = (import ./sway-keybindings.nix { inherit pkgs lib; });
      };
    };

    # Configure swaylock for all invocations (e.g. manual, lid-close, hibernate, ...).
    home.file.".config/swaylock/config" = {
      text = ''
      show-failed-attempts
      show-keyboard-layout
      indicator-caps-lock
      color=101010
      '';
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

    programs.obs-studio = {
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
    };

    services.mako = {
      enable = true;
      settings = {
        actions = true;
        markup = true;
        default-timeout = 10000;
        border-size = 0;

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

    systemd.user = {
      enable = true;

      services = {
        discord = {
          Unit = {
            Description = "Start discord on login.";
            # Wait for network to avoid "reconnecting" on startup.
            # TODO: doesn't seem to work, maybe network service isn't available in user mode?
            After = ["network-online.service"];
            Wants = ["graphical-session.target"];
          };
          Service = {
            Type = "exec";
            RemainAfterExit = true;
            ExecStart= "${pkgs.discord}/bin/discord --start-minimized";
          };
          Install = {
            WantedBy = ["graphical-session.target"];
          };
        };
      };
    };

    home.stateVersion = "24.11";
  };
}
