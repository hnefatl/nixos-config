{ pkgs, lib, ... }:

{
  imports = [ ./common.nix ];

  boot = {
    # TODO: remove once no-op.
    # Personal laptop's wifi chip driver has a bug preventing suspend/hibernate in currently-stable 6.12.
    # Enforce oldest kernel 6.14.
    kernelPackages = lib.mkIf (lib.versionOlder pkgs.linuxPackages.kernel.version "6.13") pkgs.pkgs.linuxPackages_latest;
    initrd.systemd.enable = true;

    # Replaced by lanzaboote
    loader.systemd-boot.enable = lib.mkForce false;

    # Options in https://github.com/nix-community/lanzaboote/blob/master/nix/modules/lanzaboote.nix
    lanzaboote = {
      enable = true;
      # Generated with `sbctl create-keys` per
      # https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
      pkiBundle = "/var/lib/sbctl";
      # Prevents just changing the kernel command line to gain root.
      settings.editor = false;
    };
  };

  # Once LUKS is configured and secureboot is set up, run this to enable disk auto-decryption.
  # sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7+12 --wipe-slot=tpm2 /dev/nvme0n1p2
}
