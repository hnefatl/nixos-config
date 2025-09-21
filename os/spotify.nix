{
  # Allow Spotify to discover Google Cast devices.
  networking.firewall.allowedUDPPorts = [ 5333 ];
  services.avahi.enable = true;
}