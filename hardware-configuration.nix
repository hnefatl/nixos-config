{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/5633-785D";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [ { device = "/dev/disk/by-uuid/44090b89-b355-4498-b272-4264d3d94ae8"; } ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/fb594a2d-ba40-4ed3-bc91-b1f53966b4e5";
      fsType = "btrfs";
      options = [ "subvol=root" ];
      neededForBoot = true;
    };

  fileSystems."/home/keith" =
    { device = "/dev/disk/by-uuid/fb594a2d-ba40-4ed3-bc91-b1f53966b4e5";
      fsType = "btrfs";
      options = [ "subvol=home/keith" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/fb594a2d-ba40-4ed3-bc91-b1f53966b4e5";
      fsType = "btrfs";
      options = [ "subvol=nix" "noatime" ];
      # Maybe?
      neededForBoot = true;
    };

  fileSystems."/games" =
    { device = "/dev/disk/by-uuid/15352c74-bed2-4ba3-b743-1463003519d9";
      fsType = "ext4";
      options = [ "noatime" "exec" ];
    };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
