{
  programs.waybar = {
    enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        modules-left = [ "sway/workspaces" ];
        # TODO: maybe keep if can remove window titles?
        #modules-center = ["sway/window"];

        # TODO: weather left of battery
        # TODO: volume
        # TODO: bluetooth
        # TODO: use "tray" to include system tray
        modules-right = [
          "mpris"
          "pulseaudio"
          "backlight"
          "custom/vpn"
          "network"
          "memory"
          "cpu"
          "battery"
          "clock"
        ];

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
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
        };
        backlight = {
          interval = 30;
          format = "{icon}{percent:3}%";
          format-icons = [
            "󰃞 "
            "󰃟 "
            "󰃠 "
          ];
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
        network =
          let
            base-format = "{ipaddr}";
          in
          {
            interval = 30;

            format = "{icon}${base-format}";
            format-icons = [
              "󰤟 "
              "󰤢 "
              "󰤥 "
              "󰤨 "
            ];
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
      }
    ];
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
}
