{ lib, ... }: {
  # Schema for per-machine configs levers.
  options.machine_config = {
    instance = lib.mkOption {
      type = lib.types.enum ["laptop" "desktop" "corp-laptop"];
      description = "The specific machine. Prefer depending on a machine archetype defined below, unless unwieldy.";
    };
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "Hostname for the machine.";
    };
    formFactor = lib.mkOption {
      type = lib.types.enum ["laptop" "desktop"];
      description = "The physical form-factor of the machine. To be used for common portability decisions (e.g. WiFi, Bluetooth, VPN, ...).";
    };
    hasFingerprintReader = lib.mkOption {
      type = lib.types.bool;
    };
    autoLogin = lib.mkOption {
      type = lib.types.bool;
      description = "Whether to automatically login without asking for a password.";
    };
  };
}
