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
    path = [
      pkgs.bash
      pkgs.docker-compose
    ];

    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "/pool/services/docker_configs/";
    };
  };

  networking.firewall = {
    # home-assistant
    allowedTCPPorts = [ 8123 ];
  };
  # Required to let home-assistant find google cast and other mDNS devices.
  services.avahi.enable = true;

  environment.systemPackages = [
    pkgs.docker-compose
    pkgs.nvidia-docker
  ];
}
