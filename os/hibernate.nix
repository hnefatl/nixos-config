{ config, lib, ... }:

{
  powerManagement.enable = true;

  services.logind = {
    powerKey = if config.machine_config.formFactor == "desktop" then "suspend" else "hibernate";
    powerKeyLongPress = "poweroff";
    lidSwitch = "suspend";
  };
}

