{ config, pkgs, ... }:
{
  systemd.services.sendspin-daemon = {
    description = "Sendspin Daemon";
    after = [ "network-online.target" "sound.target" ];
    wants = [ "network-online.target" "sound.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.sendspin-go}/bin/sendspin-go --daemon --name='Desktop Speakers' --audio-device='alsa_output.pci-0000_00_1f.3.analog-surround-21'";

      Restart = "always";
      RestartSec = "5s";

      DynamicUser = true;
      SupplementaryGroups = [ "audio" ];
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };
  networking.firewall.allowedTCPPorts = [ 8927 8928 ];
}
