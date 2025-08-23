{
  pkgs,
  lib,
  config,
  ...
}:

lib.mkIf (config.machine_config.formFactor == "laptop") {
  networking = {
    firewall = {
      allowedUDPPorts = [ 51820 ];
    };

    # This configuration disconnects and doesn't reconnect when I do a nixos switch, not sure why.
    #
    #wireguard = {
    #  enable = true;
    #  "interfaces.wg0" = {
    #    ips = ["10.29.0.9/32"];
    #    listenPort = 51820;

    #    privateKeyFile = "/etc/nixos/secrets/wireguard_private";

    #    peers = [{
    #      publicKey = "yKqPGe+9olnRGu8GSGVb+lOEefWJLoQjk5WqVBK8OVk=";
    #      endpoint = "vpn.keith.collister.xyz:5746";
    #      allowedIPs = ["0.0.0.0/0"];
    #      persistentKeepalive = 25;
    #    }];
    #  };
    #};

    wg-quick.interfaces."wg0" = {
      autostart = true;
      address = [ "10.29.0.9/32" ];
      dns = [ "10.20.0.1" ];
      listenPort = 51820;

      privateKeyFile = "/etc/nixos/secrets/wireguard_private";

      peers = [
        {
          publicKey = "yKqPGe+9olnRGu8GSGVb+lOEefWJLoQjk5WqVBK8OVk=";
          endpoint = "vpn.keith.collister.xyz:5746";
          allowedIPs = [ "0.0.0.0/0" ];
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
