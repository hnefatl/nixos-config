{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./common.nix ];

  # TODO: `systemd-analyze security zfs-send`?
  systemd.services = {
    zfsreplicator-dataset-permissions = {
      description = "Set ZFS dataset permissions delegation for the zfsreplicator user.";
      after = [ "zfs.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";

      script = ''
        set -x
        /run/booted-system/sw/bin/zfs allow -u zfsreplicator send,hold zroot/enc/snap
      '';
    };

    zfs-replicate = {
      description = "Replicate ZFS snapshots to off-machine backup.";
      after = [ "zfs.target" ];
      startAt = "hourly";
      serviceConfig = {
        User = "zfsreplicator";
        Group = "zfsreplicator";
      };
      script =
        let
          ssh_keys = import ../../../../common/ssh_keys.nix;
          # Inject the server's public key as a known host, otherwise ssh fails due to untrusted host.
          known_hosts_file = pkgs.writeText "zfsreplicator_known_hosts" ''
            10.20.1.3 ${ssh_keys.hosts.warthog}
          '';
        in
        ''
          set -x
          echo "TODO: do stuff here"
          sudo -u zfsreplicator /home/keith/projects/zfs-replicator/target/debug/zfs-replicator --dry_run --verbose --remote=10.20.1.3 --known_hosts_file=${known_hosts_file} --identity_file=${config.sops.secrets."zfsreplicator/id_ed25519".path} --source_dataset=zroot/enc/snap --remote_dataset=zslow/enc/device_backups/desktop
        '';
    };
  };
}
