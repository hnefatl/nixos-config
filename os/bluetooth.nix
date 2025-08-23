{ config, lib, ... }:
lib.mkIf (config.machine_config.formFactor == "laptop") {
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
}
