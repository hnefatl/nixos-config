{
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.age.keyFile = "/etc/nixos/secrets/age.key";

  # Secrets are defined at their callsite, makes local context easier.
}
