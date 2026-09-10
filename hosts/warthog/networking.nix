{ config, lib, ... }:
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

  # Music-assistant docker container already provides an mDNS server, so just enable
  # clients, don't publish.
  services.avahi.publish.enable = lib.mkForce false;
}
