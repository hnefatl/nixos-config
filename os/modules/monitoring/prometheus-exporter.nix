{ config, lib, ... }:
{
  services.prometheus = {
    enable = true;
    # Add hostname to all exported metrics.
    globalConfig.external_labels.origin_host = config.networking.hostName;

    # VictoriaMetrics instance on warthog.
    remoteWrite = [ { url = "http://warthog.local:8428/api/v1/write"; } ];

    exporters.node = {
      enable = true;
      port = 9000;

      # For list of available collectors: `nix run nixpkgs#prometheus-node-exporter -- --help`
      enabledCollectors = [
        "cpu_vulnerabilities"
        "ethtool"
        "systemd"
        "wifi"
      ];
    };

    # Tell prometheus main agent to scrape the exporters.
    scrapeConfigs = [
      {
        job_name = "node_exporter";
        static_configs = [ { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ]; } ];
      }
      (lib.mkIf config.virtualisation.docker.enable {
        job_name = "docker";
        static_configs = [ { targets = [ "127.0.0.1:9323" ]; } ];
      })
    ];
  };

  virtualisation.docker.daemon.settings = lib.mkIf config.virtualisation.docker.enable {
    # Keep this localhost for now, since docker only runs on warthog.
    metrics-addr = "127.0.0.1:9323";
  };
}
