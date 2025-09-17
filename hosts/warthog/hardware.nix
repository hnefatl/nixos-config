{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/EC4A-F86F";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  fileSystems."/" =
    { device = "zpoolroot/ephemeral/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "zpoolroot/nix";
      fsType = "zfs";
    };

  fileSystems."/persist" =
    { device = "zpoolroot/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

  fileSystems."/pool/services" =
    { device = "zfast/services";
      fsType = "zfs";
    };

  fileSystems."/pool/backup" =
    { device = "zfast/backup";
      fsType = "zfs";
      options = [
        "ro"
      ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/71d49f75-93a1-44f6-ab19-4a31ffc16508"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
