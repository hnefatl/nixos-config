{ config, lib, ... }:
let
  dataPath = "/pool/services/authelia";
in
{
  services.authelia.instances.main = {
    enable = true;
    settingsFiles = [ "/etc/nixos/hosts/warthog/modules/authelia/configuration.yaml" ];
    secrets = {
      jwtSecretFile = "${dataPath}/secrets/session_secret";
      storageEncryptionKeyFile = "${dataPath}/secrets/storage_encryption_key";
    };
  };

  systemd.services.authelia-main.serviceConfig = {
    # Let the locked-down systemd service write to the pool path.
    ReadWritePaths = dataPath;
  };
}
