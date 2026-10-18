{ config, lib, ... }:
{
  users.users.victoriametrics = {
    isSystemUser = true;
    group = "victoriametrics";
  };
  users.groups.victoriametrics = { };

  services.victoriametrics = {
    enable = true;
    listenAddress = ":8428";
    extraOptions = [ "--storageDataPath=/pool/services/monitoring/victoriametrics" ];
    retentionPeriod = "5y";
  };

  systemd.services.victoriametrics.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = config.users.users.victoriametrics.name;
    Group = config.users.users.victoriametrics.group;
    ReadWritePaths = [ "/pool/services/monitoring/victoriametrics" ];
  };

  # Allow pushes from remote machines.
  networking.firewall.allowedTCPPorts = [ 8428 ];
}
