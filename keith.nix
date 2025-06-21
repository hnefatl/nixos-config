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

  home-manager.users.keith = { pkgs, ... }: {
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
      wrapperFeatures.gtk = true;
      config = rec {
        terminal = "kitty";

	startup = [];

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

	keybindings = let
	  mod = "Mod4"; # Super/Windows/Framework key
	  caps = "Mod3"; # Caps lock rebound to Escape
	in rec {
          "${mod}+r" = "reload";
          "${mod}+Shift+r" = "restart";
          "${mod}+Shift+q" = "swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -b 'Yes, exit i3' 'i3-msg exit'";

          "${caps}+t" = "exec ${lib.getExe pkgs.kitty}";
          "${caps}+w" = "exec ${lib.getExe pkgs.firefox}";
          "${mod}+d" = "exec ${pkgs.dmenu}/bin/dmenu_run";

          "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5% ; pkill -RTMIN+10 i3blocks";
          "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5% ; pkill -RTMIN+10 i3blocks";
          "XF86AudioMute" = "exec amixer set Master toggle ; pkill -RTMIN+10 i3blocks";
          "XF86AudioPrev" = "exec playerctl -p spotify prev ; pkill -RTMIN+11 i3blocks";
          "XF86AudioNext" = "exec playerctl -p spotify next ; pkill -RTMIN+11 i3blocks";
	  # Spotify-specific, should maybe make generic player equivalents for e.g. youtube.
	  # TODO: one of my devices has different output here, maybe PC?
          "XF86AudioPlay" = "exec playerctl -p spotify play-pause ; pkill -RTMIN+11 i3blocks";
          "XF86AudioPause" = "exec playerctl -p spotify pause ; pkill -RTMIN+11 i3blocks";

          # These aren't key rebindings, it's just getting the value of the Nix variables above.
          "${mod}+bracketleft" = XF86AudioLowerVolume;
          "${mod}+bracketright" = XF86AudioRaiseVolume;
          "${mod}+p" = XF86AudioPlay;
          "${mod}+apostrophe" = XF86AudioPrev;
          "${mod}+numbersign" = XF86AudioNext;

	  # TODO: replace with semantic paths once dotfiles are ported into home-manager?
          "${mod}+slash" = "~/bin/dmenu-audio";
          "${mod}+a" = "~/bin/dmenu-emoji";

          "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
          "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";

	  # TODO: Separate path for work lockscreen?
          "${mod}+${caps}+l" = "exec ${lib.getExe pkgs.swaylock}";

	  # dmenu stdin are the prefilled options. Alternative names can be entered.
          "${mod}+Return" = "exec echo 'spotify\\nmisc' | ${lib.getExe pkgs.dmenu} -p 'Name:' | xargs swaymsg rename workspace to";

          "${mod}+q" = "kill";

          "${mod}+h" = "focus left";
          "${mod}+l" = "focus right";
          "${mod}+j" = "focus down";
          "${mod}+k" = "focus up";
          "${mod}+semicolon" = "focus parent";
          "${mod}+Shift+semicolon" = "focus child";
          "${mod}+Shift+h" = "move left";
          "${mod}+Shift+l" = "move right";
          "${mod}+Shift+j" = "move down";
          "${mod}+Shift+k" = "move up";

          "${mod}+g" = "split h";
          "${mod}+t" = "split v";
          "${mod}+s" = "layout stacking";
          "${mod}+w" = "layout tabbed";
          "${mod}+e" = "layout toggle split";

          "${mod}+f" = "fullscreen toggle";
          "${mod}+space" = "floating toggle";
          "${mod}+b" = "focus mode_toggle";

          "${mod}+n" = "workspace prev";
          "${mod}+m" = "workspace next";
          "${mod}+1" = "workspace number 1";
          "${mod}+2" = "workspace number 2";
          "${mod}+3" = "workspace number 3";
          "${mod}+4" = "workspace number 4";
          "${mod}+5" = "workspace number 5";
          "${mod}+6" = "workspace number 6";
          "${mod}+7" = "workspace number 7";
          "${mod}+8" = "workspace number 8";
          "${mod}+9" = "workspace number 9";
          "${mod}+0" = "workspace number 10";
          "${mod}+grave" = "workspace main";
          "${mod}+minus" = "workspace vert";
          "${mod}+Shift+n" = "move container to workspace prev; workspace prev";
          "${mod}+Shift+m" = "move container to workspace next; workspace next";
          "${mod}+Shift+1" = "move container to workspace number 1; workspace number 1";
          "${mod}+Shift+2" = "move container to workspace number 2; workspace number 2";
          "${mod}+Shift+3" = "move container to workspace number 3; workspace number 3";
          "${mod}+Shift+4" = "move container to workspace number 4; workspace number 4";
          "${mod}+Shift+5" = "move container to workspace number 5; workspace number 5";
          "${mod}+Shift+6" = "move container to workspace number 6; workspace number 6";
          "${mod}+Shift+7" = "move container to workspace number 7; workspace number 7";
          "${mod}+Shift+8" = "move container to workspace number 8; workspace number 8";
          "${mod}+Shift+9" = "move container to workspace number 9; workspace number 9";
          "${mod}+Shift+0" = "move container to workspace number 10; workspace number 10";
          "${mod}+Shift+grave" = "move container to workspace main; workspace main";
          "${mod}+Shift+minus" = "move container to workspace vert; workspace vert";

	  "${mod}+Alt+Shift+h" = "move workspace to output left";
	  "${mod}+Alt+Shift+l" = "move workspace to output right";
	  "${mod}+Alt+Shift+j" = "move workspace to output down";
	  "${mod}+Alt+Shift+k" = "move workspace to output up";

          "${mod}+u" = "resize grow width 5ppt";
          "${mod}+Shift+u" = "resize shrink width 5ppt";
          "${mod}+i" = "resize grow height 5ppt";
          "${mod}+Shift+i" = "resize shrink height 5ppt";

	  # TODO: printscreen
	  # TODO: notification daemon closure, like dunst. mod+x
	};
      };
    };

    # Configure swaylock for all invocations (e.g. manual, lid-close, hibernate, ...).
    home.file.".config/swaylock/config" = {
      text = ''
      show-failed-attempts
      show-keyboard-layout
      indicator-caps-lock
      color=848884
      '';
    };

    programs.kitty = lib.mkForce {
      enable = true;
      settings = {
	font_family = "family = 'Noto Mono'";
	font_size = 12.0;
	cursor = "#aaaaaa";
	background = "#333333";
	foreground = "#ffffff";
        dynamic_background_opacity = true;
	background_opacity = 0.5;
	background_blur = 5;
      };
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
