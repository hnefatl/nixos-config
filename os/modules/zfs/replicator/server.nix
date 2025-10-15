{ pkgs, lib, ... }:
let
  ssh_keys = import ../../../../common/ssh_keys.nix;
in
{
  imports = [ ./common.nix ];

  users.users.zfsreplicator = {
    # Required so that clients can SSH in.
    shell = "${pkgs.bashNonInteractive}/bin/sh";
    openssh.authorizedKeys.keys = [ ssh_keys.zfsreplicator ];
  };

  # Configure permissions per https://github.com/jimsalterjrs/sanoid/wiki/Syncoid#running-without-root.
  systemd.services.zfsreplicator-dataset-permissions = {
    description = "Set ZFS dataset permissions delegation for the zfsreplicator user.";
    after = [ "zfs.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";

    # Could consider running `zfs unallow -u zfsreplicator -r <all pools>` to clean up any previous permissions.
    # See https://openzfs.github.io/openzfs-docs/man/master/8/zfs-allow.8.html for permissions.
    # Idk why it needs mount even if running `zfs create -u` to skip mounting...
    script = ''
      set -x
      /run/booted-system/sw/bin/zfs allow -u zfsreplicator create,receive,readonly,compression,mount,mountpoint zslow/enc/device_backups
    '';
  };

  # TODO: configure sanoid to prune serverside snapshots.
}
