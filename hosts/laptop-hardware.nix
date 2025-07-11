{ config, lib, pkgs, modulesPath, ... }:

let
  warthogSamba = path: {
    device = "//10.20.1.3/" + path;
    fsType = "cifs";
    options = let
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in ["${automount_opts},credentials=/etc/nixos/secrets/warthog_samba,uid=1000,gid=100"];
  };
in
{
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/1ef8f835-086d-4f54-8226-40fcfb22bec2";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  boot.initrd.luks.devices."luks-338b49cc-7793-41d8-ba2b-fb96794f3748".device = "/dev/disk/by-uuid/338b49cc-7793-41d8-ba2b-fb96794f3748";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/A575-1C33";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];

  fileSystems."/warthog/media" = warthogSamba "media";
  fileSystems."/warthog/transfer" = warthogSamba "transfer";
  fileSystems."/warthog/docker_configs" = warthogSamba "docker_configs";

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
