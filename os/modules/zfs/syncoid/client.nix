{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./common.nix ];

  # TODO: mail on failure.
  services.syncoid = {
    interval = "hourly";

    localSourceAllow = [
      "send"
      "hold" # Essentially for mutex?
    ];

    commands = {
      "zroot/enc/snap" = {
        # TODO: either dynamically resolve hostnames, or make hostnames system-wide?
        # The syncoid user specifically can't resolve this because it's not in ssh config.
        # "syncoid@" isn't stricly necessary but it helps the Nix module realise this is a remote target.
        target = "syncoid@10.20.1.3:zslow/enc/device_backups/${config.networking.hostName}";

        sendOptions = lib.strings.concatStringsSep " " [
          "R" # Recursive + preserve properties
          "w" # Send encrypted blocks, don't decrypt in flight. Makes remote zero-trust.
        ];
        recvOptions = lib.strings.concatStringsSep " " [
          "u" # Remote shouldn't expect to mount the received filesystem (because encrypted).
          "o readonly=on" # Make received snapshots readonly.
        ];

        extraArgs =
          let
            ssh_keys = import ../../../../common/ssh_keys.nix;
            # Inject the server's public key as a known host, otherwise syncoid fails due to untrusted host.
            known_hosts_file = pkgs.writeText "syncoid_known_hosts" ''
              10.20.1.3 ${ssh_keys.hosts.warthog}
            '';
          in
          [
            "--no-sync-snap" # Don't create a new snapshot, sync existing ones.
            "--source-bwlimit=70M" # Don't saturate a 1-gigabit link with this low-priority traffic.
            "--sshoption=UserKnownHostsFile=${known_hosts_file}" # Only trust the expected server.
          ];
      };
    };
  };
}
