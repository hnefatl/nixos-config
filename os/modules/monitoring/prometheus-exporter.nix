{ config, lib, ... }:
{
  services.prometheus.exporters.node = {
    enable = true;
    port = 9000;
    openFirewall = true;

    # For list of available collectors: `nix run nixpkgs#prometheus-node-exporter -- --help`
    enabledCollectors = [
      "cpu_vulnerabilities"
      "ethtool"
      "systemd"
      "wifi"
    ];
  };

  virtualisation.docker.daemon.settings = lib.mkIf config.virtualisation.docker.enable {
    # Keep this localhost for now, since docker only runs on warthog.
    metrics-addr = "127.0.0.1:9323";
  };
}
