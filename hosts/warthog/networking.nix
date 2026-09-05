{ config, ... }:
{
  # Disable legacy stack.
  networking.useDHCP = false;

  systemd.network = {
    enable = true;

    networks."10-lan" = {
      matchConfig.Name = "eno1";
      # DHCP for ipv4, SLAAC for ipv6.
      DHCP = "ipv4";
      networkConfig = {
        MulticastDNS = true;
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };

  # Disable Avahi on e.g. docker interfaces
  services.avahi.allowInterfaces = [
    config.systemd.network.networks."10-lan".matchConfig.Name
  ];
}
