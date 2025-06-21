{ lib, config, ... }: let
  cfg = config.machine_config;
in {
  # Schema for per-machine configs levers.
  options.machine_config = {
    instance = lib.mkOption {
      type = lib.types.enum ["personal-laptop" "desktop" "work-laptop"];
      description = "The specific machine. Prefer depending on a machine archetype defined below, unless unwieldy.";
    };
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "Hostname for the machine.";
    };
    laptop = lib.mkOption {
      type = lib.types.bool;
      description = "Whether the machine is a laptop.";
    };
    hasFingerprintReader = lib.mkOption {
      type = lib.types.bool;
      description = "Whether the machine has a fingerprint reader.";
    };
  };

  # The actual config for this machine, imported from a symlinked file.
  config.machine_config = (import ./machine_config_instance.nix);
}
