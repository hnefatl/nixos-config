{
  boot.supportedFilesystems = [ "nfs" ];

  # TODO: sync with the server nixos definition somehow.
  fileSystems."/warthog/backup" = {
    device = "10.20.1.3:/pool/backup";
    fsType = "nfs";
    options = [ "noauto" "x-systemd.automount" "x-systemd.idle-timeout=600" "noatime" ];
  };
  fileSystems."/warthog/media" = {
    device = "10.20.1.3:/pool/media";
    fsType = "nfs";
    options = [ "noauto" "x-systemd.automount" "x-systemd.idle-timeout=600" "noatime" ];
  };
  fileSystems."/warthog/old_disks" = {
    device = "10.20.1.3:/pool/old_disks";
    fsType = "nfs";
    options = [ "noauto" "x-systemd.automount" "x-systemd.idle-timeout=600" "noatime" ];
  };
  fileSystems."/warthog/services" = {
    device = "10.20.1.3:/pool/services";
    fsType = "nfs";
    options = [ "noauto" "x-systemd.automount" "x-systemd.idle-timeout=600" "noatime" ];
  };
  fileSystems."/warthog/transfer" = {
    device = "10.20.1.3:/pool/transfer";
    fsType = "nfs";
    options = [ "noauto" "x-systemd.automount" "x-systemd.idle-timeout=600" "noatime" ];
  };
}
