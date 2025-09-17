{ ... }:
{
  boot = {
    initrd.systemd.enable = true;

    supportedFilesystems = ["zfs"];
    zfs = {
      forceImportRoot = false; 
    };

    loader = {
      systemd-boot.enable = true;

      timeout = 5;
      efi.canTouchEfiVariables = true;
    };
  };
}
