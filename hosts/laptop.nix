{ config, ... }: {
  imports = [ ./library.nix ];

  config.machine_config = {
    instance = "laptop";
    hostname = "laptop";
    formFactor = "laptop";
    hasFingerprintReader = true;
  };
}
