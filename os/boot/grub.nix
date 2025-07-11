{ pkgs, config, ... }:

{
  imports = [ ./common.nix ];

  # Grub neatly sorts all the previous generations of NixOS into a folder, nicer than systemd-boot.
  boot.loader.grub = {
    enable = true;
    useOSProber = false;  # Statically defined here instead (more stable, faster builds).
    efiSupport = true;  # duh
    copyKernels = true;  # copy kernels and initramfs ramdisks to /boot.
    configurationLimit = 20;
    splashImage = null;  # Text mode

    # Seems to be a longstanding bug that setting an actual device forces MBR+Bios mode, not GPT+ESP.
    # https://nixos.wiki/wiki/Dual_Booting_NixOS_and_Windows#Grub_2
    device = "nodev";

    # Install a netboot efi onto /boot as well.
    extraFiles = { "EFI/netboot/ipxe.efi" = "${pkgs.ipxe}/ipxe.efi"; };
    extraEntries = (
      if config.machine_config.instance == "desktop" then ''
        menuentry "Microsoft Windows" {
          insmod chain
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
        ''
      else ""
    ) + ''
      menuentry "Netboot" {
            insmod chain
            chainloader /EFI/netboot/ipxe.efi
      };
      menuentry 'Shutdown' {
        halt
      }
      menuentry 'restart' {
        reboot
      }
    '';
  };
}

