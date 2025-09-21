{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-amd" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/1ef8f835-086d-4f54-8226-40fcfb22bec2";
    fsType = "btrfs";
    options = [ "subvol=@" ];
  };

  boot.initrd.luks.devices."luks-338b49cc-7793-41d8-ba2b-fb96794f3748".device =
    "/dev/disk/by-uuid/338b49cc-7793-41d8-ba2b-fb96794f3748";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A575-1C33";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    {
      device = "/swapfile";
      # 64 GiB, enough for 2x RAM - not sure what happens if hibernate
      # when there's not enough space here, but don't want to find out.
      size = 64 * 1024;
    }
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
