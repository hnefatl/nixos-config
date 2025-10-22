{ config, pkgs, ... }:
{
  sops.secrets."samba_passwords/keith" = {};

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        "security" = "user";
        "hosts allow" = "10.20.";
        "hosts deny" = "0.0.0.0/0";
      };
      "transfer" = {
        "path" = "/pool/transfer";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };

  systemd.services.set-samba-user-passwords = {
    description = "Set Samba user passwords.";
    after = [ "samba.target" ];
    wantedBy = [ "samba-smbd.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
    };

    # smbpasswd asks for password then same password as confirmation.
    script = ''
      set -x
      (for x in 1 2 ; do
        cat ${config.sops.secrets."samba_passwords/keith".path}
        echo
      done) | ${pkgs.samba}/bin/smbpasswd -a keith
    '';
  };
}

