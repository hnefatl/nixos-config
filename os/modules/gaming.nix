# Use e.g. `nixos-option services.fprintd.enable` to query the value of the current config.

{ config, ... }:

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
}
