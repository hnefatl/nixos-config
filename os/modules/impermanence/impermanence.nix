{ config, pkgs, lib, ... }:
let
  impermanent_root_dataset = "${config.standard_filesystems.pool_names.root}/enc/ephemeralroot";
  persistent_root_dataset = "${config.standard_filesystems.pool_names.root}/enc/snap/persistentroot";
in
{
  # This config relies on values set in this module, and assumes the machine is using this layout.
  imports = [ ../../../hosts/standard-filesystems.nix ];

  fileSystems = {
    # Impermanent systems use a different root dataset than normal, because it doesn't need autosnapshots.
    "/".device = lib.mkForce impermanent_root_dataset;

    "/persist" = {
      device = persistent_root_dataset;
      fsType = "zfs";
      neededForBoot = true;
    };

    # Required so that impermanence has the filesystem available for setting user passwords:
    # https://github.com/Mic92/sops-nix?tab=readme-ov-file#setting-a-users-password
    "/etc/nixos".neededForBoot = true;
  };

  # Rollback to empty root once devices are available and before mounted.
  boot.initrd.systemd.services.zfs-rollback-root = {
    description = "ZFS rollback root to empty.";

    wantedBy = [ "initrd.target" ];
    after = [ "zfs-import-${config.standard_filesystems.pool_names.root}.service" ];
    before = [ "sysroot.mount" ];

    path = [ pkgs.zfs ];

    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      zfs rollback -r ${impermanent_root_dataset}@empty && echo "rollback complete"
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
      # Secure boot keys
      "/var/lib/sbctl/"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
}
