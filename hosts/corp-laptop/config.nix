{ config, ... }:
{
  imports = [ ../library.nix ];

  config.machine_config = {
    instance = "corp-laptop";
    hostname = "kcollister9";
    formFactor = "laptop";
    autoLogin = false;
    isWork = true;
    primaryMonitor = "eDP-1";
  };
}
