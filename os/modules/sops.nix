{
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.keyFile = "/etc/nixos/secrets/age.key";

  # Needs other manual steps anyway, this makes it clearer what's happening.
  sops.age.generateKey = false;

  # Secrets are defined at their callsite, makes local context easier.
}
