{ pkgs, lib, ... }:
let
  dataPath = "/pool/monitoring/prometheus";
  serverPort = 9090;
  # https://prometheus.io/docs/prometheus/latest/configuration/configuration/
  config = {
    global.scrape_interval = "1m";
    scrape_configs = [
      {
        job_name = "warthog";
        # Prometheus exporter and docker exporter
        static_configs = [{ targets = ["warthog:9000" "127.0.0.1:9323" ]; } ];
      }
      {
        job_name = "desktop";
        static_configs = [ { targets = [ "desktop:9000" ]; } ];
      }
      {
        job_name = "laptop";
        static_configs = [ { targets = [ "laptop:9000" ]; } ];
      }
    ];
  };
  configFile = (pkgs.formats.yaml { }).generate "prometheus.yml" config;

  cmdLineArgs = [
    "--config.file=${configFile}"
    "--web.listen-address=0.0.0.0:${toString serverPort}"
    "--storage.tsdb.path=${dataPath}"
    # Unclear why these can't be provided as config file params, the docs claim they can.
    "--storage.tsdb.retention.time=90d"
    "--storage.tsdb.retention.size=100GB"
  ];
in
{
  services.prometheus.enable = true;

  # TODO: replace with reverse proxy static route
  networking.firewall.allowedTCPPorts = [ serverPort ];

  # The NixOS module has some weird defaults, this overwrites them to be simpler.
  systemd.services.prometheus.serviceConfig = {
    ExecStart = lib.mkForce ("${pkgs.prometheus}/bin/prometheus " + lib.concatStringsSep " " cmdLineArgs);
    ReadWritePaths = dataPath;
  };
}
