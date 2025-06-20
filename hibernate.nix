{ config, pkgs, ... }:

{
  powerManagement.enable = true;

  services.logind = {
    powerKey = "hibernate";
    powerKeyLongPress = "poweroff";
    # Configuring IdleAction and IdleActionSec didn't work: possibly i3wm not supporting idle detection.
    # Instead worked around by adding a timer in i3 config.
  };
}

