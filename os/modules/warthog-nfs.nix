let
  options = [
    "noauto"
    "x-systemd.automount"
    "x-systemd.idle-timeout=600"
    "x-systemd.device-timeout=5s"
    "x-systemd.mount-timeout=5s"
    "noatime"
  ];
in
{
  boot.supportedFilesystems = [ "nfs" ];

  # TODO: sync with the server nixos definition somehow.
  fileSystems."/warthog/backup" = {
    device = "[2a01:4b00:bd20:7010:230:59ff:fe28:d000]:/pool/backup";
    fsType = "nfs";
    inherit options;
  };
  fileSystems."/warthog/media" = {
    device = "[2a01:4b00:bd20:7010:230:59ff:fe28:d000]:/pool/media";
    fsType = "nfs";
    inherit options;
  };
  fileSystems."/warthog/old_disks" = {
    device = "[2a01:4b00:bd20:7010:230:59ff:fe28:d000]:/pool/old_disks";
    fsType = "nfs";
    inherit options;
  };
  fileSystems."/warthog/services" = {
    device = "[2a01:4b00:bd20:7010:230:59ff:fe28:d000]:/pool/services";
    fsType = "nfs";
    inherit options;
  };
  fileSystems."/warthog/transfer" = {
    device = "[2a01:4b00:bd20:7010:230:59ff:fe28:d000]:/pool/transfer";
    fsType = "nfs";
    inherit options;
  };
  fileSystems."/warthog/camera" = {
    device = "[2a01:4b00:bd20:7010:230:59ff:fe28:d000]:/pool/camera";
    fsType = "nfs";
    inherit options;
  };
}
