{ config, pkgs, ... }:
let
  sd_uuid = "FB06-F55D";
  camera-backup = pkgs.callPackage ../scripts/camera-backup.nix { };
in
{
  environment.systemPackages = [ pkgs.rawtherapee ];

  fileSystems."/camera" = {
    device = "/dev/disk/by-uuid/${sd_uuid}";
    options = [
      "noauto"
      "ro"
      "uid=keith"
      "gid=users"
      "noexec"
      "nosuid"
      "nodev"
    ];
  };

  # See available attrs using `udevadm info /dev/...`
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEMS=="usb", ENV{ID_FS_UUID}=="FB06-F55D", ENV{SYSTEMD_WANTS}+="${config.systemd.services.camera-backup.name}"
  '';

  # A separate systemd service to avoid mounting in the udev rule, which is Bad™.
  systemd.services.camera-backup = rec {
    description = "Backup SD card, mounting if not already";
    requires = [
      "dbus.service"
      "graphical.target"
      "camera.mount"
      "warthog-camera.mount"
    ];
    # Only start this service once all the deps are done.
    after = requires;

    serviceConfig = {
      User = "keith";
      Group = "users";
      ExecStart = "${camera-backup}/bin/camera-backup";
    };
  };
}
