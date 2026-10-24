{ config, pkgs, lib, ... }:
{
  users.users.msmtp = {
    isSystemUser = true;
    group = config.users.groups.msmtp.name;
  };
  users.groups.msmtp = { };

  sops.secrets."email_accounts/password" = {
    owner = config.users.users.msmtp.name;
    group = config.users.users.msmtp.group;
  };

  programs.msmtp = {
    enable = true;
    extraConfig = ''
      auth           on
      tls            on
      tls_trust_file /etc/ssl/certs/ca-certificates.crt
      account        default
      host           smtp.gmail.com
      port           465
      tls_starttls   off
      from           hnefatl@gmail.com
      user           hnefatl
      passwordeval   "${pkgs.coreutils}/bin/cat /run/secrets/email_accounts/password"
    '';
  };

  systemd.services.msmtpd = {
    description = "msmtpd";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      Type = "simple";
      User = config.users.users.msmtp.name;
      Group = config.users.users.msmtp.group;

      ExecStart = lib.strings.concatStringsSep " " [
        "${pkgs.msmtp}/bin/msmtpd"
        "--log=syslog"
      ];

      Restart = "on-failure";
      RestartSec = "5s";
      ProtectSystem = "strict";
      ProtectHome = true;
      StateDirectory = "msmtpd";
      ReadWritePaths = "/tmp";
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
    };
  };
}
