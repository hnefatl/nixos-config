{ pkgs, lib, ... }:
{
  imports = [ ../msmtp.nix ];

  services.zfs.zed = {
    settings = {
      # For testing
      # ZED_NOTIFY_VERBOSE = 1;
      ZED_EMAIL_PROG = lib.getExe pkgs.msmtp;
      ZED_EMAIL_ADDR = "hnefatl+zed@gmail.com";
    };
  };
}
