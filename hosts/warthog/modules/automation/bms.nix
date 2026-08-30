{ inputs, pkgs, lib, ... }:
{
  users.users.bms = {
    isSystemUser = true;
    group = "bms";
  };
  users.groups.bms = {};

  systemd.services.bms = {
    description = "Building Management System";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      Type = "simple";
      User = "bms";
      Group = "bms";

      ExecStart = "${pkgs.hello}/bin/hello";
      WorkingDirectory = "/var/lib/bms";

      Restart = "on-failure";
      RestartSec = "5s";
      ProtectSystem = "strict";
      ProtectHome = true;
      StateDirectory = "bms";
    };
  };
}
