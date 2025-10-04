{ config, lib, ... }:
{
  imports = [ ./common.nix ];

  boot = {
    initrd.systemd.enable = true;

    loader = {
      systemd-boot.enable = true;
      # KVM has a bit of latency, allow a bit longer.
      timeout = if config.machine_config.instance == "warthog" then 5 else 1;
    };
  };
}
