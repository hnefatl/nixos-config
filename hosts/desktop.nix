{ config, ... }: {
  imports = [ ./library.nix ];

  config.machine_config = {
    instance = "desktop";
    hostname = "desktop";
    formFactor = "desktop";
    hasFingerprintReader = false;
  };
}
