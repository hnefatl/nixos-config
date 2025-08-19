{ pkgs, lib, ... }:
{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "12h";
    matchBlocks = {
      "warthog" = {
        host = "10.20.1.3";
        user = "root";
      };
      "router" = {
        host = "10.20.0.1";
        user = "root";
      };
    };
  };
  services.ssh-agent.enable = true;
}
