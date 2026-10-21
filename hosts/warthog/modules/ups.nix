# https://wiki.nixos.org/wiki/Uninterruptible_power_supply
{
  config,
  pkgs,
  lib,
  ...
}:
{
  sops.secrets."nut_password" = {
    owner = config.power.ups.upsmon.user;
    group = config.power.ups.upsmon.group;
    mode = "0440"; # Allow user and group read, so prometheus job below can read.
  };

  environment.systemPackages = [ pkgs.nut ];

  power.ups = {
    enable = true;
    mode = "standalone";

    ups."ups" = {
      description = "Eaton 3S Gen2 UPS";

      # driver name from https://networkupstools.org/stable-hcl.html
      driver = "usbhid-ups";
      # usbhid-ups driver always use value "auto"
      port = "auto";

      # TODO: look into whether battery.runtime is provided by the UPS and use that if possible.
      # Query device parameters with `upsc ups@localhost`.
      directives = [
        # To make sure "restore power on AC" in BIOS triggers, power needs to be cut then restored once utility
        # returns.
        # There's an edge case where a shutdown starts then utility power is restored before it completes. In this case
        # the shutdown computer never saw the power off then on, so it doesn't automatically power back on.
        #
        # To workaround this, we need to artificially cut the UPS power before the battery is actually depleted, then
        # restore power once utility comes back.
        # Because this should only happen once a shutdown has been requested, this shouldn't cause availability loss.
        # The UPS cut command is sent from server to UPS in the final stages of shutdown, and starts a UPS-side
        # countdown before it cuts power to the sockets.

        # 30s after server shuts down, the UPS should cut power.
        "offdelay = 30"
        # 60s after the UPS has cut power, allow it to restore power if the utility feed returns.
        "ondelay = 90"

        # What percentage upsmon should initiate shutdown at.
        # https://eg.eaton.com/ups-battery-runtime/en-gb/3S850F (the B variant but close enough).
        # At time of writing, server+base networking uses ~80W steadystate. Rounding to 100W, and consulting the
        # runtime graph above, we should get ~25mins. 20% is 5mins, which should be enough time to shut down.
        "lowbatt = 20"

        # Apparently ignores any initial lowbattery warnings triggered when the power first drops? Prevents early
        # trigger?
        "ignorelb"
      ];
    };

    upsd.listen = [
      {
        address = "127.0.0.1";
        port = 3493;
      }
    ];

    # This isn't a system user, this is a NUT user.
    users."nut-admin" = {
      passwordFile = config.sops.secrets."nut_password".path;
      upsmon = "primary";
    };

    upsmon = {
      monitor."ups" = {
        system = "ups@localhost";
        type = "primary";
        powerValue = 1;
        user = "nut-admin";
        passwordFile = config.sops.secrets."nut_password".path;
      };

      settings =
        let
          # nixfmt makes this really ugly... but doing this manually is formatted even uglier.
          unpack =
            as:
            lib.mapAttrsToList (k: v: [
              k
              v
            ]) as;
        in
        {
          # Copied from the NixOS docs.
          NOTIFYMSG = unpack {
            ONLINE = ''"UPS %s: On line power."'';
            ONBATT = ''"UPS %s: On battery."'';
            LOWBATT = ''"UPS %s: Battery is low."'';
            REPLBATT = ''"UPS %s: Battery needs to be replaced."'';
            FSD = ''"UPS %s: Forced shutdown in progress."'';
            SHUTDOWN = ''"Auto logout and shutdown proceeding."'';
            COMMOK = ''"UPS %s: Communications (re-)established."'';
            COMMBAD = ''"UPS %s: Communications lost."'';
            NOCOMM = ''"UPS %s: Not available."'';
            NOPARENT = ''"upsmon parent dead, shutdown impossible."'';
          };
          NOTIFYFLAG = unpack {
            ONLINE = "SYSLOG+WALL";
            ONBATT = "SYSLOG+WALL";
            LOWBATT = "SYSLOG+WALL";
            REPLBATT = "SYSLOG+WALL";
            FSD = "SYSLOG+WALL";
            SHUTDOWN = "SYSLOG+WALL";
            COMMOK = "SYSLOG+WALL";
            COMMBAD = "SYSLOG+WALL";
            NOCOMM = "SYSLOG+WALL";
            NOPARENT = "SYSLOG+WALL";
          };
          RBWARNTIME = 216000;
          NOCOMMWARNTIME = 300;
          FINALDELAY = 0;
        };
    };
  };

  services.prometheus = lib.mkIf config.services.prometheus.enable {
    scrapeConfigs =
      let
        exporterAddress = "${config.services.prometheus.exporters.nut.listenAddress}:${toString config.services.prometheus.exporters.nut.port}";
      in
      [
        {
          job_name = "nut_exporter";
          metrics_path = "/ups_metrics";
          params = {
            server = [ "127.0.0.1" ];
          };
          static_configs = [ { targets = [ "ups" ]; } ];

          # Magic relabelling from https://github.com/DRuggeri/nut_exporter that's necessary for this to work?
          relabel_configs = [
            {
              source_labels = [ "__address__" ];
              target_label = "__param_ups";
            }
            {
              source_labels = [ "__param_ups" ];
              target_label = "instance";
            }
            {
              target_label = "__address__";
              replacement = exporterAddress;
            }
          ];
        }
      ];

    exporters.nut = {
      enable = true;
      listenAddress = "127.0.0.1";
      nutServer = "127.0.0.1";
      nutUser = "nut-admin";
      passwordPath = config.sops.secrets."nut_password".path;
    };
  };
  # Give access to the password file.
  users.groups.${config.power.ups.upsmon.group}.members = [ "nut-exporter" ];
}
