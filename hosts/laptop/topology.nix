{ config, ... }:
with config.lib.topology;
{
  topology.self.interfaces.wlp192s0 = {
    network = "ssid";
    physicalConnections = [
      (mkConnection "ap2" "WiFi")
    ];
  };
}
