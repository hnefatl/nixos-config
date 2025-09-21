{ lib, ... }:
{
  # Schema for per-machine configs levers.
  options.machine_config = {
    instance = lib.mkOption {
      type = lib.types.enum [
        "laptop"
        "desktop"
        "corp-laptop"
        "warthog"
      ];
      description = "The specific machine. Prefer depending on a machine archetype defined below, unless unwieldy.";
    };
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "Hostname for the machine.";
    };
    formFactor = lib.mkOption {
      type = lib.types.enum [
        "laptop"
        "desktop"
        "server"
      ];
      description = "The physical form-factor of the machine. To be used for common portability decisions (e.g. WiFi, Bluetooth, VPN, ...).";
    };
    autoLogin = lib.mkOption {
      type = lib.types.bool;
      description = "Whether to automatically login without asking for a password.";
    };
    isWork = lib.mkOption {
      type = lib.types.bool;
      description = "Whether the device is a work device.";
    };
    primaryMonitor = lib.mkOption {
      type = lib.types.str;
      description = "Primary monitor for the machine.";
    };
  };
}
