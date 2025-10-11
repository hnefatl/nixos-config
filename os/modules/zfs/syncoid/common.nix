{ config, lib, ... }:
let
  ssh_keys = import ../../../../common/ssh_keys.nix;
in
{
  sops.secrets."syncoid/id_ed25519" = {
    owner = config.users.users.syncoid.name;
    group = config.users.users.syncoid.group;
  };

  users.users.syncoid = {
    # syncoid runs an SSH test to start with, which cd's to the user home. To make
    # sure this works even on a freshly provisioned machine, ensure that directory
    # exists.
    # Note that the syncoid service already sets the home directory to /var/lib/syncoid.
    createHome = lib.mkForce true;
    openssh.authorizedKeys.keys = [ ssh_keys.syncoid ];
  };
  users.groups.syncoid = { };

  services.syncoid = {
    enable = true;
    # User and group default to "syncoid".
    # Use the same SSH key for all syncoid instances - access to a client
    # already gives SSH access to all the backups, and access to the server
    # is already game over.
    sshKey = "/run/secrets/syncoid/id_ed25519";

    commonArgs = [
      "--compress=none" # All snapshots are already compressed
    ];
  };
}
