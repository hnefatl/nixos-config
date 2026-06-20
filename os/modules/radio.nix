{
  hardware.rtl-sdr.enable = true;
  boot.blacklistedKernelModules = [ "dvb_usb_rtl28xxu" ];

  users.users.keith.extraGroups = ["plugdev"];
}
