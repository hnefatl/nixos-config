{
  # Requires manual user password configuration:
  #   $ sudo smbpasswd -a keith
  #
  # TODO: use a systemd service to configure this from a committed secret.

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
}

