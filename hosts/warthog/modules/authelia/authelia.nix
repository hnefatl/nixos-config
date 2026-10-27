{ config, lib, pkgs-unstable, ... }:
let
  autheliaData = "/pool/services/authelia";
  redisData = "/pool/services/redis-authelia";
in
{
  services.authelia.instances."main" = {
    enable = true;
    package = pkgs-unstable.authelia;
    settingsFiles = [ "/etc/nixos/hosts/warthog/modules/authelia/configuration.yaml" ];
    secrets = {
      jwtSecretFile = "${autheliaData}/secrets/jwt_secret";
      storageEncryptionKeyFile = "${autheliaData}/secrets/storage_encryption_key";
      sessionSecretFile = "${autheliaData}/secrets/session_secret";
    };
  };
  systemd.services."authelia-main".serviceConfig = {
    # Let the locked-down systemd service write to the pool path.
    ReadWritePaths = autheliaData;
  };
  # Make sure authelia can access the UDS for talking with redis.
  users.users."authelia-main".extraGroups = [ "redis-authelia" ];

  services.redis.servers."authelia" = {
    enable = true;
    settings = {
      dir = lib.mkForce redisData;
    };
  };
  systemd.services."redis-authelia".serviceConfig = {
    ReadWritePaths = redisData;
  };
}
