{
  config,
  pkgs,
  lib,
  ...
}:
let
  mod = "Mod4"; # Super/Windows/Framework key
  caps = "Mod5"; # Caps lock
  terminal = config.wayland.windowManager.sway.config.terminal;
  dmenu-emoji = pkgs.callPackage ../../scripts/dmenu-emoji.nix { };
  dmenu-audio = pkgs.callPackage ../../scripts/dmenu-audio.nix { };
  brightnessctl = "${lib.getExe pkgs.brightnessctl}";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  playerctl = "${lib.getExe pkgs.playerctl}";
  screencap = pkgs.callPackage ../../scripts/screencap.nix { };
  systemctl = "${pkgs.systemd}/bin/systemctl";
  mute-application = pkgs.callPackage ../../scripts/mute-application.nix { };
  mute-source = lib.getExe (pkgs.callPackage ../../scripts/mute-source.nix { });

  spotify-op = op: "${playerctl} -p spotify ${op} , exec pkill -SIGRTMIN+11 i3blocks";
  pactl-op = op: "${pactl} ${op} , exec pkill -SIGRTMIN+10 i3blocks";
in
{
  # Disable default keybindings
  wayland.windowManager.sway.config.keybindings = { };

  # I want to use the full config syntax like `--locked`, so it's easier to just
  # do everything as a raw config file.
  wayland.windowManager.sway.config.keybindings = {
    # But some things need to be overridden by corp profile...
    "${caps}+w" = "exec ${lib.getExe pkgs.firefox}";
    "${mod}+grave" = "workspace main";
    "${mod}+Shift+grave" = "move container to workspace main; workspace main";
  };
  wayland.windowManager.sway.extraConfig = ''
    bindsym ${mod}+r reload
    bindsym ${mod}+Shift+q exec swaynag -t warning -m 'Do you really want to exit?' -b 'Yes' 'swaymsg exit'

    bindsym ${caps}+t exec ${terminal}
    bindsym ${caps}+f exec ${terminal} -x ${lib.getExe pkgs.ranger}
    bindsym ${caps}+h exec ${terminal} -x ${lib.getExe pkgs.htop}
    bindsym ${caps}+c exec ${terminal} --title calculator -x ${lib.getExe pkgs.bc} --quiet
    bindsym ${caps}+n exec ${terminal} --title notepad -x ${lib.getExe pkgs.neovim}
    bindsym ${caps}+g exec ${systemctl} --user is-active --quiet gammastep && ${systemctl} --user stop gammastep || systemctl --user start gammastep
    bindsym ${mod}+d  exec ${lib.getExe pkgs.fuzzel}

    # Wayland global keybind -> Discord in XWayland workaround.
    bindsym Alt+e exec ${pkgs.xdotool}/bin/xdotool key alt+e
    bindsym Alt+q exec ${pkgs.xdotool}/bin/xdotool key alt+q

    bindsym --locked XF86AudioLowerVolume       exec ${pactl-op "set-sink-volume @DEFAULT_SINK@ -5%"}
    bindsym --locked XF86AudioRaiseVolume       exec ${pactl-op "set-sink-volume @DEFAULT_SINK@ +5%"}
    bindsym --locked Shift+XF86AudioLowerVolume exec ${pactl-op "set-sink-volume @DEFAULT_SINK@ -1%"}
    bindsym --locked Shift+XF86AudioRaiseVolume exec ${pactl-op "set-sink-volume @DEFAULT_SINK@ +1%"}
    bindsym --locked XF86AudioMute              exec ${pactl-op "set-sink-mute @DEFAULT_SINK@ toggle"}
    bindsym --locked XF86AudioMicMute           exec ${mute-source}
    bindsym          ${mod}+XF86AudioMute       exec ${mute-application}/bin/mute-application
    bindsym --locked XF86AudioPrev  exec ${spotify-op "previous"}
    bindsym --locked XF86AudioNext  exec ${spotify-op "next"}
    bindsym --locked XF86AudioPlay  exec ${spotify-op "play-pause"}
    bindsym --locked XF86AudioPause exec ${spotify-op "pause"}
    # Generic media play/pause
    bindsym ${mod}+XF86AudioPlay  exec ${playerctl} play-pause , exec pkill -SIGRTMIN+11 i3blocks
    bindsym ${mod}+XF86AudioPause exec ${playerctl} pause , exec pkill -SIGRTMIN+11 i3blocks

    bindsym --locked ${mod}+bracketleft        exec ${pactl-op "set-sink-volume @DEFAULT_SINK@ -5%"}
    bindsym --locked ${mod}+bracketright       exec ${pactl-op "set-sink-volume @DEFAULT_SINK@ +5%"}
    bindsym --locked ${mod}+Shift+bracketleft  exec ${pactl-op "set-sink-volume @DEFAULT_SINK@ -1%"}
    bindsym --locked ${mod}+Shift+bracketright exec ${pactl-op "set-sink-volume @DEFAULT_SINK@ +1%"}
    bindsym --locked ${mod}+p                  exec ${spotify-op "play-pause"}
    bindsym --locked ${mod}+apostrophe         exec ${spotify-op "previous"}
    bindsym --locked ${mod}+numbersign         exec ${spotify-op "next"}
    bindsym          ${mod}+backspace          exec ${mute-source}

    bindsym ${mod}+slash exec ${dmenu-audio}/bin/dmenu-audio
    bindsym ${mod}+a     exec ${dmenu-emoji}/bin/dmenu-emoji

    bindsym --locked XF86MonBrightnessUp   exec ${brightnessctl} set +5%
    bindsym --locked XF86MonBrightnessDown exec ${brightnessctl} set 5%-

    bindsym ${mod}+${caps}+l exec ${lib.getExe pkgs.swaylock}

    # dmenu stdin are the prefilled options. Alternative names can be entered.
    bindsym ${mod}+Return exec echo 'spotify\nmisc' | ${lib.getExe pkgs.fuzzel} --dmenu -p 'Name:' | xargs swaymsg rename workspace to

    bindsym ${mod}+q kill

    bindsym ${mod}+h       focus left
    bindsym ${mod}+l       focus right
    bindsym ${mod}+j       focus down
    bindsym ${mod}+k       focus up
    bindsym ${mod}+Shift+h move left
    bindsym ${mod}+Shift+l move right
    bindsym ${mod}+Shift+j move down
    bindsym ${mod}+Shift+k move up

    bindsym ${mod}+semicolon       focus parent
    bindsym ${mod}+Shift+semicolon focus child

    bindsym ${mod}+g split h
    bindsym ${mod}+t split v
    bindsym ${mod}+s layout stacking
    bindsym ${mod}+w layout tabbed
    bindsym ${mod}+e layout toggle split

    bindsym ${mod}+f     fullscreen toggle
    bindsym ${mod}+space floating toggle
    bindsym ${mod}+b     focus mode_toggle

    bindsym ${mod}+n           workspace prev
    bindsym ${mod}+m           workspace next
    bindsym ${mod}+1           workspace number 1
    bindsym ${mod}+2           workspace number 2
    bindsym ${mod}+3           workspace number 3
    bindsym ${mod}+4           workspace number 4
    bindsym ${mod}+5           workspace number 5
    bindsym ${mod}+6           workspace number 6
    bindsym ${mod}+7           workspace number 7
    bindsym ${mod}+8           workspace number 8
    bindsym ${mod}+9           workspace number 9
    bindsym ${mod}+0           workspace number 10
    bindsym ${mod}+minus       workspace vert
    bindsym ${mod}+Shift+n     move container to workspace prev; workspace prev
    bindsym ${mod}+Shift+m     move container to workspace next; workspace next
    bindsym ${mod}+Shift+1     move container to workspace number 1; workspace number 1
    bindsym ${mod}+Shift+2     move container to workspace number 2; workspace number 2
    bindsym ${mod}+Shift+3     move container to workspace number 3; workspace number 3
    bindsym ${mod}+Shift+4     move container to workspace number 4; workspace number 4
    bindsym ${mod}+Shift+5     move container to workspace number 5; workspace number 5
    bindsym ${mod}+Shift+6     move container to workspace number 6; workspace number 6
    bindsym ${mod}+Shift+7     move container to workspace number 7; workspace number 7
    bindsym ${mod}+Shift+8     move container to workspace number 8; workspace number 8
    bindsym ${mod}+Shift+9     move container to workspace number 9; workspace number 9
    bindsym ${mod}+Shift+0     move container to workspace number 10; workspace number 10
    bindsym ${mod}+Shift+minus move container to workspace vert; workspace vert

    bindsym ${mod}+Alt+Shift+h move workspace to output left
    bindsym ${mod}+Alt+Shift+l move workspace to output right
    bindsym ${mod}+Alt+Shift+j move workspace to output down
    bindsym ${mod}+Alt+Shift+k move workspace to output up

    bindsym ${mod}+u       resize grow width 5px or 5ppt
    bindsym ${mod}+Shift+u resize shrink width 5px or 5ppt
    bindsym ${mod}+i       resize grow height 5px or 5ppt
    bindsym ${mod}+Shift+i resize shrink height 5px or 5ppt

    bindsym ${mod}+x         exec ${pkgs.mako}/bin/makoctl dismiss
    bindsym ${mod}+Shift+x = exec ${pkgs.mako}/bin/makoctl restore
    # Handle actionable notifications
    bindsym ${mod}+c         exec ${pkgs.mako}/bin/makoctl menu -- ${lib.getExe pkgs.fuzzel} --dmenu

    bindsym Print        exec ${screencap}/bin/screencap printscreen
    bindsym Alt+Print    exec ${screencap}/bin/screencap delay_printscreen
    bindsym ${mod}+Print exec ${screencap}/bin/screencap record

    # Flags prevent blurry apps with Wayland.
    bindsym ${caps}+d ${
      if config.programs.vesktop.enable then
        "exec ${pkgs.vesktop}/bin/vesktop --ozone-platform=wayland"
      else if config.programs.discord.enable then
        "exec ${pkgs.discord}/bin/discord --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto"
      else
        # TODO: replace with e.g. opening the default browser
        "exec echo open https://discord.com/channels/@me"
    }
    bindsym ${caps}+s exec ${pkgs.spotify}/bin/spotify --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto
  '';
}
