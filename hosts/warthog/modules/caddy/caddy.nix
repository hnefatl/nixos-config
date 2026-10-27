{ lib, pkgs-unstable, ... }:
{
  services.caddy = {
    package = pkgs-unstable.caddy;
    enable = true;
    configFile = ./Caddyfile;
    email = "hnefatl@gmail.com";
    openFirewall = true;
  };
}
