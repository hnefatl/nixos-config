{ config, pkgs, lib, ... }:

{
  imports = [
    ./swayidle.nix
    ./unfree.nix
    ./feh.nix
    ./mpv.nix
  ];

  home = rec {
    username = "keith";
    homeDirectory = "/home/${config.home.username}";

    packages = with pkgs; [
      discord
      spotify
      noto-fonts
      noto-fonts-color-emoji
      nerd-fonts.symbols-only
      wireguard-tools
      # Needed for e.g. blueman-applet icon.
      hicolor-icon-theme
    ] ++ (
      # Remote desktop
      if config.machine_config.instance == "laptop" then [moonlight-qt] else []
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
        serif = ["Noto Serif"];
        sansSerif = ["Noto Sans"];
        monospace = ["Noto Sans Mono"];
        emoji = ["Noto Color Emoji"];
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
    extraOptions = lib.mkIf (config.machine_config.instance == "desktop") ["--unsupported-gpu"];
    wrapperFeatures.gtk = true;
    config = rec {
      terminal = "kitty";
      defaultWorkspace = "workspace number 1";
      # Set the primary monitor in X11 for xwayland apps. Prevents e.g. games defaulting to wrong screen.
      startup = [{ command = "${lib.getExe pkgs.xorg.xrandr} --output ${config.machine_config.primaryMonitor} --primary"; always = true; }];

      # Cycle around containers in the same workspace.
      # TODO: Still need something like i3-cycle to define "horizontal-only" workspace wrapping (or like tabbed-workspace-direction-only).
      # focus.wrapping = "workspace";

      fonts = {
        names = ["Noto Sans"];
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

      bars = [{
        position = "top";
        trayOutput = "primary";
        command = "${pkgs.waybar}/bin/waybar";
      }];

      keybindings = (import ./sway-keybindings.nix { inherit pkgs lib; });
    };
    extraConfig = ''
      # If a game is focused, disable idle
      for_window [class="steam_app*"] inhibit_idle focus
    '';
  };

    programs.waybar = {
      enable = true;
      settings = [{
        layer = "top";
        position = "top";
        modules-left = ["sway/workspaces"];
        # TODO: maybe keep if can remove window titles?
        #modules-center = ["sway/window"];

        # TODO: weather left of battery
        # TODO: volume
        # TODO: bluetooth
        # TODO: use "tray" to include system tray
        modules-right = ["mpris" "pulseaudio" "backlight" "custom/vpn" "network" "memory" "cpu" "battery" "clock"];

        clock = {
          interval = 30;
          format = "{:%Y-%m-%d %H:%M:%S}";
        };
        battery = {
          interval = 30;
          format = "{icon} {capacity:3}%";
          tooltip-format = ''
            Power: {power:.2f}W
            Remaining: {time}
            Cycles: {cycles}
            Health: {health}%'';
          states = {
            "warning" = 30;
            "critical" = 10;
          };
          # Icons are allocated to "100÷#icons" ranges of the value.
          # https://github.com/Alexays/Waybar/issues/1618#issuecomment-1186207028
          format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
        };
        backlight = {
          interval = 30;
          format = "{icon}{percent:3}%";
          format-icons = ["󰃞 " "󰃟 " "󰃠 "];
        };
        cpu = {
          format = " {usage:2}%";
          interval = 5;
        };
        memory = {
          interval = 5;
          format = " {percentage:2}%";
          #tooltip-format = ''
          #  Total:{used:2.1f}GiB/{total:2.1f}GiB (~{avail:2.1f}GiB available)
          #  Swap:{swapUsed:2.1f}GiB/{swapTotal:2.1f}GiB (~{swapAvail:2.1f}GiB available)'';
          tooltip-format = "Total:\t{used:2.1f}GiB/{total:2.1f}GiB (~{avail:2.1f}GiB available)\nSwap:\t{swapUsed:2.1f}GiB/{swapTotal:2.1f}GiB (~{swapAvail:2.1f}GiB available)";
        };
        network = let base-format = "{ipaddr}"; in {
          interval = 30;

          format = "{icon}${base-format}";
          format-icons = ["󰤟 " "󰤢 " "󰤥 " "󰤨 "];
          format-ethernet = "󰈀 ${base-format}";
          format-linked = "󰤫 ${base-format}";
          format-disconnected = "󰤮 ${base-format}";
          format-disabled = "󰤮 ${base-format}";

          tooltip-format = ''
            ESSID: {essid}
            Strength: {signaldBm}dBm
            Frequency: {frequency}GHz
            Up: {bandwidthUpBytes}
            Down: {bandwidthDownBytes}'';
        };
        "custom/vpn" = {
          interval = 30;
          format = "{}";
          exec = "ip link show wg0 | grep -qF 'state UP' && echo '󰌆 ' || echo '󰷖 '";
          #format-ethernet = "󰌆 ";
          #format-disabled = "󰷖 ";
          #format-disconnected = "󰷖 ";
        };
        pulseaudio = {
          # TODO: Customise icon by device type
          format = "{icon}{volume:3}%";
          format-icons = {
            "default" = "󰕾 ";
            "default-muted" = "󰖁 ";
          };
        };
        mpris = {
          player = "spotify";
          # TODO: not being respected?
          max-length = 100;
          format = "{status_icon} {title} - {artist} ({album})";
          status-icons = {
            # TODO: colour?
            "playing" = "󰐊";
            "paused" = "󰏤";
          };
          tooltip-format = ''
            Title: {title}
            Album: {album}
            Artist: {artist}
            Length: {length}'';
          interval = 5;
        };
      }];
      # Initially copied from https://github.com/robertjk/dotfiles/blob/253b86442dae4d07d872e8b963fa33b5f8819594/.config/waybar/style.css
      style = ''
        @keyframes blink-warning {
          70% { color: white; }
          to {
            color: white;
            background-color: orange;
          }
        }
        @keyframes blink-critical {
          70% { color: white; }
          to {
            color: white;
            background-color: red;
          }
        }
        
        /* Reset all styles */
        * {
          border: none;
          border-radius: 0;
          min-height: 0;
          margin: 0;
          padding: 0;
        }
        
        /* The whole bar */
        #waybar {
          background: #222222;
          color: #888888;
          font-family: Noto Sans Mono, Symbols Nerd Font;
          font-size: 14px;
        }
        
        /* Each module */
        #clock,
        #backlight,
        #battery,
        #cpu,
        #memory,
        #custom.vpn,
        #brightness,
        #pulseaudio,
        #temperature {
          padding-left: 14px;
        }
        
        #battery {
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }
        #battery.warning { color: orange; }
        #battery.critical { color: red; }
        #battery.warning.discharging {
          animation-name: blink-warning;
          animation-duration: 3s;
        }
        #battery.critical.discharging {
          animation-name: blink-critical;
          animation-duration: 2s;
        }
        
        #cpu { /* No styles */ }
        #cpu.warning { color: orange; }
        #cpu.critical { color: red; }
        
        #memory {
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }
        #memory.warning { color: orange; }
        #memory.critical {
          color: red;
          animation-name: blink-critical;
          animation-duration: 2s;
        }
        
        #mode {
          background: #64727D;
          border-top: 2px solid white;
          /* To compensate for the top border and still have vertical centering */
          padding-bottom: 2px;
        }
        
        #network { /* No styles */ }
        #network.disconnected { color: orange; }

        #pulseaudio { /* No styles */ }
        #pulseaudio.muted { /* No styles */ }
        
        #custom-spotify {
          color: rgb(102, 220, 105);
        }
        
        #temperature { /* No styles */ }
        #temperature.critical { color: red; }
        
        #tray { /* No styles */ }
        
        #window { font-weight: bold; }
        
        #workspaces button {
          border-top: 2px solid transparent;
          /* To compensate for the top border and still have vertical centering */
          padding-bottom: 2px;
          padding-left: 10px;
          padding-right: 10px;
          color: #888888;
        }
        #workspaces button.focused {
          border-color: #4c7899;
          color: white;
          background-color: #285577;
        }
        #workspaces button.urgent {
          border-color: #c9545d;
          color: #c9545d;
        }
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
    configPackages = [pkgs.xdg-desktop-portal-wlr];
    extraPortals = [pkgs.xdg-desktop-portal-wlr];
  };

  systemd.user = {
    enable = true;

    services = {
      discord = lib.mkIf (!config.machine_config.isWork) {
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
}
