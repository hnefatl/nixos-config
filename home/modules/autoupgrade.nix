{ inputs, ... }:
{
  services.home-manager.autoUpgrade = {
    enable = true;
    useFlake = true;
    flakeDir = "/etc/nixos/home";
    frequency = "01:00";
  };
}
