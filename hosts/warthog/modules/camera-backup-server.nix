{
  config,
  pkgs,
  inputs,
  ...
}:
let
  camera-backup = inputs.camera-backup.packages."x86_64-linux".default;
  port = 4361;
in
{
  systemd.services.camera-backup-server = rec {
    description = "Provide camera backup service.";
    wantedBy = [ "multi-user.target" ];
    requires = [ "pool-camera.mount" ];
    # Only start this service once all the deps are done.
    after = requires;

    serviceConfig = {
      User = "keith";
      Group = "users";
      ExecStart = "${camera-backup}/bin/server --directory=/pool/camera/raw --address=0.0.0.0:${toString port}";
    };
  };

  # Exposed on local network+VPN, but not exposed to internet.
  networking.firewall.allowedTCPPorts = [ port ];
}
