{ config, lib, ... }:
{
  imports = [ ./common.nix ];

  boot = {
    initrd.systemd.enable = true;

    loader.systemd-boot = {
      enable = true;
      netbootxyz.enable = true;
      memtest86.enable = true;
    };
  };
}
