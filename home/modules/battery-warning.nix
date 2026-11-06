{ config, pkgs, ... }:
{
  systemd.user = {
    services."battery-warning" = {
      Install.WantedBy = [ "graphical-session.target" ];
      # Stop this service if the graphical session goes away.
      Unit.PartOf = [ "graphical-session.target" ];

      Service = {
        Type = "oneshot";
        StateDirectory = "battery-warning";

        ExecStart = pkgs.writeShellScript "battery-warning" ''
          BAT_PATH="/sys/class/power_supply/BAT1"
          echo "Using battery $BAT_PATH"
          STATE_FILE="$STATE_DIRECTORY/notification_id"
          echo "Using state file $STATE_FILE"

          if [ ! -d "$BAT_PATH" ]; then
            echo "No file $BAT_PATH"
            exit 1
          fi
          STATUS=$(cat "$BAT_PATH/status")
          CAPACITY=$(cat "$BAT_PATH/capacity")

          if [ -s "$STATE_FILE" ] ; then
            LAST_ID=$(cat "$STATE_FILE" || true)
          else
            LAST_ID="0"
          fi

          if [ "$STATUS" = "Discharging" ] && [ "$CAPACITY" -le 25 ]; then
            ${pkgs.libnotify}/bin/notify-send \
              --urgency=critical \
              --icon=battery-low \
              --print-id \
              --replace-id="$LAST_ID" \
              "Low Battery" \
              "Battery is at $CAPACITY%." \
            >"$STATE_FILE"
            echo "Capacity at $CAPACITY%, showing notification."
          elif [ -s "$STATE_FILE" ] ; then
            ${pkgs.mako}/bin/makoctl dismiss "$LAST_ID"
            rm "$STATE_FILE"
            echo "Battery charging, cleaned up state file"
          else
            echo "Capacity at $CAPACITY%, not showing notification."
          fi
        '';
      };
    };

    timers."battery-warning" = {
      Install.WantedBy = [ "timers.target" ];
      Timer = {
        OnBootSec = "10s";
        OnUnitActiveSec = "30s";
        # Run within 5s of target time. Default is 1min, which makes sub-minute timers useless.
        AccuracySec = "5s";
      };
    };
  };
}
