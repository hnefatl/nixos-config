{ lib, ... }:

{
  imports = [ ./common.nix ];

  boot.loader.systemd-boot = {
    # Replaced by lanzaboote
    # TODO: check whether remaining menu items have any effect
    enable = lib.mkForce false;
    editor = false;
    netbootxyz.enable = true;
    memtest86.enable = true;
  };
  boot.lanzaboote = {
    enable = true;
    # Generated with `sbctl create-keys` per
    # https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
    pkiBundle = "/var/lib/sbctl";
  };
}

