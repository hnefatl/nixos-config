{
  # softflowd traffic in
  networking.firewall.allowedUDPPorts = [ 2055 ];

  services.telegraf = {
    enable = true;
    extraConfig = {
      inputs = {
        netflow = [
          {
            service_address = "udp://:2055";
            protocol = "ipfix";
          }
        ];
      };

      # Convert from influxdb-style metrics to victoriametrics timeseries fields.
      # These discovered mostly through trial and error using what shows up in Grafana...
      processors = {
        converter = [
          {
            fields.tag = [
              "direction"
              "src"
              "dst"
              "src_port"
              "src_tos"
              "out_snmp"
              "dst_port"
              "tcp_flags"
              "protocol"
              "ip_version"
              "first_switched"
              "last_switched"
              "icmp_code"
              "icmp_type"
            ];
          }
        ];
      };

      outputs = {
        # This is influxdb protocol but into victoriametrics.
        influxdb = [
          {
            urls = [ "http://127.0.0.1:8428" ];
            database = "softflowd";
            skip_database_creation = true;
          }
        ];
      };
    };
  };
}
