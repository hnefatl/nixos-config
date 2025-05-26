{ config, pkgs, ... }:

{
  powerManagement.enable = true;

  systemd.sleep.extraConfig = ''
    AllowHybridSleep=yes
  '';

  services.logind = {
    # Couldn't get hybrid-sleep working: NVIDIA errors about not using driver procfs suspend interface.
    # Suspect that NixOS doesn't configure systemd-sleep correctly to interact with nvidia's systemd units.
    powerKey = "suspend";
    powerKeyLongPress = "poweroff";
    # Configuring IdleAction and IdleActionSec didn't work: possibly i3wm not supporting idle detection.
    # Instead worked around by adding a timer in i3 config.
  };
}

