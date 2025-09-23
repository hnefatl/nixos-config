{ config, ... }:
{
  sops.secrets."email_accounts/password" = {
    owner = config.users.users.keith.name;
    group = config.users.users.keith.group;
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
      passwordeval   "cat /run/secrets/email_accounts/password"
    '';
  };
}
