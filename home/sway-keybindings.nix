{ pkgs, lib, ... }:

let
  mod  = "Mod4"; # Super/Windows/Framework key
  caps = "Escape"; # Caps lock rebound to Escape
  dmenu-emoji = pkgs.callPackage ./scripts/dmenu-emoji.nix { inherit pkgs; };
  dmenu-audio = pkgs.callPackage ./scripts/dmenu-audio.nix { inherit pkgs; };
in rec {
  "${mod}+r" = "reload";
  "${mod}+Shift+q" = "swaynag -t warning -m 'Do you really want to exit?' -b 'Yes' 'swaymsg exit'";

  "${caps}+t" = "exec ${lib.getExe pkgs.kitty}";
  "${caps}+w" = "exec ${lib.getExe pkgs.firefox}";
  "${caps}+f" = "exec ${lib.getExe pkgs.kitty} ${lib.getExe pkgs.ranger}";
  "${caps}+h" = "exec ${lib.getExe pkgs.kitty} ${lib.getExe pkgs.htop}";
  "${mod}+d" = "exec ${pkgs.dmenu}/bin/dmenu_run";

  # Wayland global keybind -> Discord in XWayland workaround.
  "Alt+e" = "exec ${pkgs.xdotool}/bin/xdotool key alt+e";
  "Alt+q" = "exec ${pkgs.xdotool}/bin/xdotool key alt+q";

  "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5% ; pkill -RTMIN+10 i3blocks";
  "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5% ; pkill -RTMIN+10 i3blocks";
  "XF86AudioMute" = "exec amixer set Master toggle ; pkill -RTMIN+10 i3blocks";
  "XF86AudioPrev" = "exec playerctl -p spotify previous ; pkill -RTMIN+11 i3blocks";
  "XF86AudioNext" = "exec playerctl -p spotify next ; pkill -RTMIN+11 i3blocks";
  # Spotify-specific, should maybe make generic player equivalents for e.g. youtube.
  # TODO: one of my devices has different output here, maybe PC?
  "XF86AudioPlay" = "exec playerctl -p spotify play-pause ; pkill -RTMIN+11 i3blocks";
  "XF86AudioPause" = "exec playerctl -p spotify pause ; pkill -RTMIN+11 i3blocks";
  # Testing generic media play/pause
  "${mod}+XF86AudioPlay" = "exec playerctl play-pause ; pkill -RTMIN+11 i3blocks";
  "${mod}+XF86AudioPause" = "exec playerctl pause ; pkill -RTMIN+11 i3blocks";

  # These aren't key rebindings, it's just getting the value of the Nix variables above.
  "${mod}+bracketleft" = XF86AudioLowerVolume;
  "${mod}+bracketright" = XF86AudioRaiseVolume;
  "${mod}+p" = XF86AudioPlay;
  "${mod}+apostrophe" = XF86AudioPrev;
  "${mod}+numbersign" = XF86AudioNext;

  # TODO: replace with semantic paths once dotfiles are ported into home-manager?
  "${mod}+slash" = "exec ${dmenu-audio}/bin/dmenu-audio";
  "${mod}+a" = "exec ${dmenu-emoji}/bin/dmenu-emoji";

  "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
  "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";

  # TODO: Separate path for work lockscreen?
  "${mod}+${caps}+l" = "exec ${lib.getExe pkgs.swaylock-effects}";

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

  "${mod}+u" = "resize grow width 5px or 5ppt";
  "${mod}+Shift+u" = "resize shrink width 5px or 5ppt";
  "${mod}+i" = "resize grow height 5px or 5ppt";
  "${mod}+Shift+i" = "resize shrink height 5px or 5ppt";

  "${mod}+x" = "exec ${pkgs.mako}/bin/makoctl dismiss";
  "${mod}+Shift+x" = "exec ${pkgs.mako}/bin/makoctl restore";
  # Handle actionable notifications
  "${mod}+c" = "exec ${pkgs.mako}/bin/makoctl menu dmenu";

  "Print" = "exec ${pkgs.sway-contrib.grimshot}/bin/grimshot --notify --cursor copy anything";
  "${mod}+Print" = "${Print} --wait $(echo '3\\n5' | dmenu -p 'Delay:')";

  "${caps}+d" = "exec ${pkgs.discord}/bin/discord";
  "${caps}+s" = "exec ${pkgs.spotify}/bin/spotify";
}
