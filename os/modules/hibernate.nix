{ config, lib, ... }:

{
  powerManagement.enable = true;

  services.logind.settings.Login = {
    HandlePowerKey = if config.machine_config.formFactor == "desktop" then "suspend" else "hibernate";
    HandlePowerKeyLongPress = "poweroff";
    HandleLidSwitch = "suspend";
  };
}
