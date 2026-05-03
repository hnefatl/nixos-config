{
  networking.useDHCP = false;

  systemd.network = {
    enable = true;
    networks."10-lan" = {
      matchConfig.Name = "eno1";
      DHCP = "ipv4";
      linkConfig.RequiredForOnline = "routable";
    };
  };
  # Enable DNS lookups
  services.resolved.enable = true;
}
