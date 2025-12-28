{ pkgs, ... }:
{
  programs.vesktop.enable = true;
  systemd.user.services.vesktop = {
    Unit = {
      Description = "Start vesktop on login.";
      After = [ "network-online.service" ];
      Wants = [ "graphical-session.target" ];
    };
    Service = {
      Type = "exec";
      RemainAfterExit = true;
      ExecStart = "${pkgs.vesktop}/bin/vesktop --start-minimized --ozone-platform=wayland";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
