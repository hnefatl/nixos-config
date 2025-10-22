{
  pkgs,
  config,
  lib,
  ...
}:

{
  imports = [ ./systemd.nix ];

  boot = {
    initrd.systemd.enable = true;

    # Replaced by lanzaboote
    loader.systemd-boot.enable = lib.mkForce false;

    # Options in https://github.com/nix-community/lanzaboote/blob/master/nix/modules/lanzaboote.nix
    lanzaboote = {
      enable = true;
      # Generated with `sbctl create-keys` per
      # https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
      # These are just used for signing the OS, so don't need backing up. If they're lost,
      # can just disable secure boot in the BIOS and re-enroll.
      pkiBundle = "/var/lib/sbctl";
      # Prevents just changing the kernel command line to gain root.
      settings.editor = false;
    };
  };

  # Once secureboot is set up, LUKS autodecryption can be configured if needed using:
  #   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7+12 --wipe-slot=tpm2 /dev/nvme0n1p2
  # This seems to need to be done after secure boot is configured.
}
