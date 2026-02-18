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
    device = "10.20.1.3:/pool/backup";
    fsType = "nfs";
    inherit options;
  };
  fileSystems."/warthog/media" = {
    device = "10.20.1.3:/pool/media";
    fsType = "nfs";
    inherit options;
  };
  fileSystems."/warthog/old_disks" = {
    device = "10.20.1.3:/pool/old_disks";
    fsType = "nfs";
    inherit options;
  };
  fileSystems."/warthog/services" = {
    device = "10.20.1.3:/pool/services";
    fsType = "nfs";
    inherit options;
  };
  fileSystems."/warthog/transfer" = {
    device = "10.20.1.3:/pool/transfer";
    fsType = "nfs";
    inherit options;
  };
  fileSystems."/warthog/camera" = {
    device = "10.20.1.3:/pool/camera";
    fsType = "nfs";
    inherit options;
  };
}
