{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.discord.enable = true;
  home = {
    # Fix blur on wayland
    shellAliases = {
      discord = "discord --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto";
    };
  };
  systemd.user.services.discord = lib.mkIf (!config.machine_config.isWork && !config.programs.vesktop.enable) {
    Unit = {
      Description = "Start discord on login.";
      # Wait for network to avoid "reconnecting" on startup.
      # TODO: doesn't seem to work, maybe network service isn't available in user mode?
      After = [ "network-online.service" ];
      Wants = [ "graphical-session.target" ];
    };
    Service = {
      Type = "exec";
      RemainAfterExit = true;
      ExecStart = "${pkgs.discord}/bin/discord --start-minimized --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
