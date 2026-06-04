{ pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    # Prep for field being deleted from upstream.
    enableDefaultConfig = false;

    settings = {
      "*".addKeysToAgent = "12h";

      "desktop" = {
        host = "desktop";
        hostname = "desktop.local";
      };
      "pc" = {
        host = "pc";
        hostname = "desktop.local";
      };
      "warthog" = {
        host = "warthog";
        hostname = "warthog.local";
      };
      "router" = {
        host = "router";
        hostname = "router.local";
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
        hostname = "ap2.local";
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
