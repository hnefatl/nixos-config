{ lib, ... }:
{
  imports = [ ../../os/boot/common.nix ];

  boot = {
    initrd.systemd.enable = true;

    loader = {
      systemd-boot.enable = true;
      # KVM has a bit of latency, allow a bit longer.
      timeout = 5;
    };
  };
}
