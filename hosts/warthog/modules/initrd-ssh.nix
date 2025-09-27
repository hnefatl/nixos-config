{ lib, ... }:
{
  boot.initrd = {
    # Make ethernet driver available.
    availableKernelModules = [ "e1000e" ];

    network = {
      enable = true;

      ssh = {
        enable = true;

        hostKeys = [
          # Needs to be manually provided on host installation.
          # This is put into initrd secrets, so isn't stored in the Nix store but is
          # visible plaintext on the boot partition, so this key is insecure.
          # For initrd SSH access the risk is low though, as long as it's only used for that.
          "/etc/ssh/initrd_ssh_host_ed25519_key"
        ];

        authorizedKeys =
          let
            keys = import ../../../common/ssh_keys.nix;
          in
          [
            keys.keith.laptop
            keys.keith.desktop
          ];
      };
    };

    systemd = {
      enable = true;
      # Reuse existing systemd-network config.
      network = (import ../networking.nix).systemd.network;
    };
  };
}
