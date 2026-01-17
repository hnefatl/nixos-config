{ pkgs, ... }:
let
  sd_device = "/dev/disk/by-uuid/FB06-F55D";
in
{
  environment.systemPackages = [ pkgs.rawtherapee ];

  fileSystems."/camera" = {
    device = sd_device;
    options = [
      "noauto"
      "uid=keith"
      "gid=users"
      "noexec"
      "nosuid"
      "nodev"
    ];
  };

  systemd.services.camera-automount = {
    description = "Automount camera SD card on insertion";
    wantedBy = [ "default.target" ];
    path = [
      pkgs.udevil
      pkgs.procps
      pkgs.udisks
    ];
    serviceConfig.ExecStart = "${pkgs.udevil}/bin/devmon --exec-on-device '${sd_device}' 'mount /camera'";
  };
}
