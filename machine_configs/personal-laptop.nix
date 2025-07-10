{ config, ... }: {
  imports = [ ./library.nix ];

  config.machine_config = {
    instance = "personal-laptop";
    hostname = "laptop";
    formFactor = "laptop";
    hasFingerprintReader = true;
  };
}
