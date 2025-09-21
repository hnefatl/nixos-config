{ pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "12h";

    matchBlocks = {
      "desktop" = {
        host = "desktop";
        hostname = "10.20.2.5";
      };
      "pc" = {
        host = "pc";
        hostname = "10.20.2.5";
      };
      "warthog" = {
        host = "warthog";
        hostname = "10.20.1.3";
      };
      "router" = {
        host = "router";
        hostname = "10.20.0.1";
        user = "root";
      };
      "pikvm" = {
        host = "pikvm";
        hostname = "10.20.1.5";
        user = "root";
      };
      "router_remote" = {
        host = "router_remote";
        hostname = "vpn.keith.collister.xyz";
        user = "root";
      };
      "ap2" = {
        host = "ap2";
        hostname = "10.20.0.3";
        user = "root";
      };
      "crash" = {
        host = "crash";
        hostname = "10.20.1.8";
        user = "keith";
      };
      "parents_pi" = {
        host = "parents_pi";
        hostname = "10.29.0.8";
        user = "root";
      };
      "octoprint" = {
        host = "octoprint";
        hostname = "10.20.1.7";
        user = "pi";
      };
    };
  };
  services.ssh-agent.enable = true;
}
