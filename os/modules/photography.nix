{ pkgs, ... }:
let
  sd_uuid = "FB06-F55D";
  camera-mount-and-store = pkgs.callPackage ../scripts/camera-mount-and-store.nix { };
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
    ACTION=="add", SUBSYSTEMS=="usb", ENV{ID_FS_UUID}=="FB06-F55D", ENV{SYSTEMD_WANTS}+="camera-automount.service"
  '';

  # A separate systemd service to avoid mounting in the udev rule, which is Bad™.
  systemd.services.camera-automount = {
    description = "Mount and backup SD card";
    after = [
      "dbus.service"
      "graphical.target"
    ];
    serviceConfig.ExecStart = "${camera-mount-and-store}/bin/camera-mount-and-store";
  };
}
