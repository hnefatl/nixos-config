{ pkgs, lib, ... }:
{
  imports = [ ./msmtp.nix ];

  services.smartd = {
    enable = true;
    autodetect = true;
    notifications = {
      # For testing if mail works.
      # test = true;
      mail = {
        enable = true;
        mailer = lib.getExe pkgs.msmtp;
        sender = "hnefatl@gmail.com";
        recipient = "hnefatl+smartd@gmail.com";
      };
      # Don't spam on testing reload, emails are sufficient.
      wall.enable = false;
      x11.enable = false;
    };
  };
}
