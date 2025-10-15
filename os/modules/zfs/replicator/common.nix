{ config, lib, ... }:
{
  sops.secrets."zfsreplicator/id_ed25519" = {
    owner = config.users.users.zfsreplicator.name;
    group = config.users.users.zfsreplicator.group;
  };

  users.users.zfsreplicator = {
    isSystemUser = true;
    home = "/var/lib/zfsreplicator";
    createHome = true;
    group = "zfsreplicator";
  };
  users.groups.zfsreplicator = { };
}
