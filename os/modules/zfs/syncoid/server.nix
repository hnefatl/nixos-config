{ pkgs, lib, ... }:
{
  imports = [ ./common.nix ];

  users.users.syncoid = {
    # Required so that clients can SSH in.
    shell = "${pkgs.bashNonInteractive}/bin/sh";
  };

  # Configure permissions per https://github.com/jimsalterjrs/sanoid/wiki/Syncoid#running-without-root.
  systemd.services.syncoid-dataset-permissions = {
    description = "Set ZFS dataset permissions delegation for the syncoid user.";
    after = [ "zfs.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";

    # Could consider running `zfs unallow -u syncoid -r <all pools>` to clean up any previous permissions.
    # See https://openzfs.github.io/openzfs-docs/man/master/8/zfs-allow.8.html for permissions.
    script = ''
      set -x
      /run/booted-system/sw/bin/zfs allow -u syncoid create,receive,rollback,destroy,readonly,userprop zslow/enc/device_backups
    '';
  };

  # TODO: configure sanoid to prune serverside snapshots.

  # Hides a warning on the client side.
  environment.systemPackages = [ pkgs.mbuffer ];
}
