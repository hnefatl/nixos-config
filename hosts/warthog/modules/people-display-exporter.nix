{ inputs, ... }:
{
  systemd.services.people-display-exporter = rec {
    description = "people-display-exporter service.";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${inputs.people-display}/bin/exporter --directory=/pool/camera/raw --address=0.0.0.0:${toString port}";
    };
  };

  # Exposed on local network+VPN, but not exposed to internet.
  networking.firewall.allowedTCPPorts = [ port ];
}
