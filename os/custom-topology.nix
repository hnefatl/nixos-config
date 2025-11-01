# Custom topology rules.
#
# - systemd-network interface names:
#   https://www.freedesktop.org/wiki/Software/systemd/PredictableNetworkInterfaceNames/

# TODO: encode DHCP leases in Nix, build router configuration from that.

# Full schema:
# https://oddlama.github.io/nix-topology/topology-options.html
{ config, ... }:
with config.lib.topology;
{
  networks.lan = {
    name = "LAN";
    cidrv4 = "10.20.0.0/16";
  };
  networks.ssid.name = "SSID";
  networks.mac.name = "MAC";

  nodes = {
    internet = mkInternet { };

    router = mkRouter "Router" {
      info = "MikroTik hEX S";
      interfaceGroups = [
        [
          "wan@eth0"
          "lan2@eth0"
          "lan3@eth0"
          "lan4@eth0"
          "lan5@eth0"
        ]
      ];
      connections."wan@eth0" = mkConnection "internet" "*";
    };
    ap2 = mkRouter "AP1" {
      info = "MikroTik hAP ac²";
      interfaceGroups = [
        [ "WiFi" ]
        [
          "wan something"
          "eth something"
        ]
      ];
      connections."wan something" = mkConnection "router" "lan2@eth0";
    };
  };
}
