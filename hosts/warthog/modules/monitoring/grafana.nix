{ config, ... }:
{
  sops.secrets."grafana/secret_key" = {
    owner = config.users.users.grafana.name;
    group = config.users.users.grafana.group;
  };
  sops.secrets."grafana/admin_user" = {
    owner = config.users.users.grafana.name;
    group = config.users.users.grafana.group;
  };
  sops.secrets."grafana/admin_password" = {
    owner = config.users.users.grafana.name;
    group = config.users.users.grafana.group;
  };

  services.grafana = {
    enable = true;
    dataDir = "/pool/services/monitoring/grafana";
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3829;
        domain = "grafana.warthog.keith.collister.xyz";
        enforce_domain = true;
      };
      security = {
        secret_key = "$__file{/run/secrets/grafana/secret_key}";
        admin_user = "$__file{/run/secrets/grafana/admin_user}";
        admin_password = "$__file{/run/secrets/grafana/admin_password}";
        cookie_secure = true;
        cookie_samesite = "strict";
      };
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "VictoriaMetrics";
          type = "prometheus";
          url = "http://127.0.0.1:8428";
        }
      ];
    };
    settings.smtp.enabled = true;
  };
}
