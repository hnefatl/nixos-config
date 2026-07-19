{ config, ... }:
{
  services.sunshine = {
    enable = true;
    autoStart = config.machine_config.instance == "desktop";
    capSysAdmin = true;
    openFirewall = true;
  };
}
