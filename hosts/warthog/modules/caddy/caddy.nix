{ lib, ... }:
{
  services.caddy = {
    enable = true;
    configFile = ./Caddyfile;
    email = "hnefatl@gmail.com";
    openFirewall = true;
  };
}
