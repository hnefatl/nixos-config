{
  users.users.atticd = {
    isSystemUser = true;
    group = "atticd";
  };
  users.groups.atticd = {};

  services.atticd = {
    enable = true;
    mode = "monolithic";

    # This needs to be manually created, see
    # https://docs.attic.rs/admin-guide/deployment/nixos.html#generating-the-credentials-file
    environmentFile = "/etc/nixos/machine_secrets/atticd.env";
    settings = {
      # Listens only on localhost, traefik hosts a redirect here to provide HTTPS.
      listen = "0.0.0.0:7840";
      api-endpoint = "https://attic.warthog.keith.collister.xyz/";

      database.url = "sqlite:///pool/attic/server.db?mode=rwc";
      storage = {
        type = "local";
        path = "/pool/attic";
      };

      # ZFS already does compression.
      compression.type = "none";

      # Keep artifacts for a week, check every 12 hours.
      garbage-collection = {
        interval = "12 hours";
        default-retention-period = "1 week";
      };
    };
  };

  # TODO: would be nice to expose port only on localhost, and have traefik resolve it locally.
  # Not possible while traefik is in a docker container?
  networking.firewall.allowedTCPPorts = [ 7840 ];
}
