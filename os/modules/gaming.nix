# Use e.g. `nixos-option services.fprintd.enable` to query the value of the current config.

{ config, lib, ... }:

{
  programs.steam =
    let
      isDesktop = config.machine_config.instance == "desktop";
    in
    {
      enable = true;
      # Only run the desktop as a "game provider server", to keep laptop slim.
      remotePlay.openFirewall = isDesktop; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = isDesktop; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = isDesktop; # Open ports in the firewall for Steam Local Network Game Transfers
    };

  programs.gamemode = {
    enable = true;
    settings.general.inhibit_screensaver = 0;
  };

  # GPU crashes tracked by
  # https://gitlab.freedesktop.org/mesa/mesa/-/work_items/16158
  # or
  # https://gitlab.freedesktop.org/drm/amd/-/work_items/5711
  environment.sessionVariables.VKD3D_CONFIG = lib.mkIf (config.machine_config.instance == "desktop") "single_queue";

  systemd.user.services.steam = lib.mkIf (config.machine_config.instance == "desktop") {
    enable = true;
    description = "Launch steam on startup";
    wantedBy = [ "graphical-session.target" ];
    serviceConfig.ExecStart = "${config.programs.steam.package}/bin/steam -silent %U";
  };
}
