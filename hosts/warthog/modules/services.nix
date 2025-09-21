{ pkgs, ... }:
{
  hardware.nvidia-container-toolkit = {
    enable = true;
  };

  virtualisation = {
    containers.enable = true;

    docker = {
      enable = true;
      logDriver = "json-file";
      autoPrune.enable = true;
    };
  };

  systemd.services.start-services = {
    description = "Start server services";
    script = "./up ; echo 'Server services started'";
    path = [ pkgs.bash pkgs.docker-compose ];

    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "/pool/services/docker_configs/";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 8123 ];
  };

  environment.systemPackages = [
    pkgs.docker-compose
    pkgs.nvidia-docker
  ];
}
