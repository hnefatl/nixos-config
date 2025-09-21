{ config, ... }:
{
  imports = [ ../library.nix ];

  config.machine_config = {
    instance = "desktop";
    hostname = "desktop";
    formFactor = "desktop";
    autoLogin = true; # Secure environment
    isWork = false;
    primaryMonitor = "DP-1";
  };
}
