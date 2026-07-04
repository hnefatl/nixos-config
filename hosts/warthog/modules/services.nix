{ pkgs, ... }:
{
  imports = [
    ./bambuddy.nix
  ];

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

  systemd.services.docker = {
    serviceConfig = {
      Restart = "always";
      RestartSec = "5s";
    };

    # Make sure Docker restarts after an upgrade.
    after = [ "nixos-autoupgrade.service" ];
    requires = [ "nixos-autoupgrade.service" ];

    unitConfig = {
      StartLimitIntervalSec = 0; # Don't limit startups
    };
  };

  systemd.services.start-services = {
    description = "Start server services";
    script = "./up";
    path = [
      pkgs.bash
      pkgs.docker-compose
    ];

    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/pool/services/docker_configs/";
      RestartSec = "5s";
    };
    unitConfig = {
      StartLimitIntervalSec = 0; # Don't limit startups
    };
  };

  networking.firewall = {
    allowedTCPPorts = [
      # home-assistant
      8123
    ];
  };
  # Required to let home-assistant find google cast and other mDNS devices.
  services.avahi.enable = true;

  environment.systemPackages = [
    pkgs.docker-compose
    pkgs.nvidia-docker
  ];
}
