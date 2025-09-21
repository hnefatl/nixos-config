{ config, ... }:
{
  imports = [ ../library.nix ];

  config.machine_config = {
    instance = "laptop";
    hostname = "laptop";
    hostid = "90a8bf3d";
    formFactor = "laptop";
    autoLogin = false; # Secure boot and assumed insecure environment
    isWork = false;
    primaryMonitor = "eDP-1";
  };
}
