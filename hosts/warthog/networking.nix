{
  networking.useDHCP = false;

  systemd.network = {
    enable = true;
    networks."10-lan" = {
      matchConfig.Name = "eno1";
      DHCP = "ipv4";
      networkConfig.MulticastDNS = true;
      linkConfig.RequiredForOnline = "routable";
    };
  };
}
