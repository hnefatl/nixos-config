{ config, lib, ... }:

# TODO: get hibernation working on laptop, will need to configure a swapfile.
lib.mkIf (config.machine_config.instance == "desktop") {
  powerManagement.enable = true;

  services.logind = {
    powerKey = if config.machine_config.formFactor == "desktop" then "suspend" else "hibernate";
    powerKeyLongPress = "poweroff";
    # Idle detection here didn't seem to work in i3, instead added an exec to i3 config.
    # TODO: figure out what to do on Sway.
  };
}

