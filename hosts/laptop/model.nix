{ config, ... }:
{
  imports = [ ../library.nix ];

  config.machine_config = {
    instance = "laptop";
    hostname = "laptop";
    formFactor = "laptop";
    autoLogin = false; # Secure boot and assumed insecure environment
    isWork = false;
    primaryMonitor = "eDP-1";
  };
}
