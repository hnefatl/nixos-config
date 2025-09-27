{ pkgs, ... }:
{
  # Rollback to empty root once devices are available and before mounted.
  boot.initrd.systemd.services.zfs-rollback-root = {
    description = "ZFS rollback root to empty.";

    wantedBy = [ "initrd.target" ];
    # zroot must match the name of the root zpool.
    after = [ "zfs-import-zroot.service" ];
    before = [ "sysroot.mount" ];

    path = [ pkgs.zfs ];

    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      zfs rollback -r zroot/ephemeral/root@empty && echo "rollback complete"
    '';
  };

  environment.persistence."/persist" = {
    enable = true;
    hideMounts = true;
    directories = [
      {
        directory = "/etc/nixos";
        user = "keith";
        group = "users";
        mode = "u=rwx,g=rx,o=";
      }
      "/var/log"
      "/var/lib/nixos"
      "/etc/ssh/"
      # Don't yell at me for sudo'ing
      "/var/db/sudo/lectured/"
      # Don't pull docker images from scratch each time.
      "/var/lib/docker/"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
}
