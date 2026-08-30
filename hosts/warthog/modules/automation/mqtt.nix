{ config, pkgs, ... }:
{
  sops.secrets."mosquitto/passwords/homeassistant".owner = config.systemd.services.mosquitto.serviceConfig.User;
  sops.secrets."mosquitto/passwords/zigbee2mqtt".owner = config.systemd.services.mosquitto.serviceConfig.User;
  sops.templates."mosquitto/passwords/zigbee2mqtt.yaml" = {
    owner = config.systemd.services.zigbee2mqtt.serviceConfig.User;
    content = ''pass: "${config.sops.placeholder."mosquitto/passwords/zigbee2mqtt"}"'';
  };
  sops.secrets."mosquitto/passwords/bms".owner = config.systemd.services.bms.serviceConfig.User;

  services.mosquitto = {
    enable = true;
    listeners = [{
      users.homeassistant = {
        acl = [
          "readwrite homeassistant/#"
          "readwrite zigbee2mqtt/#"
          "read $SYS/#"
        ];
        passwordFile = config.sops.secrets."mosquitto/passwords/homeassistant".path;
      };
      users.zigbee2mqtt = {
        acl = [
          "readwrite homeassistant/#"
          "readwrite zigbee2mqtt/#"
        ];
        passwordFile = config.sops.secrets."mosquitto/passwords/zigbee2mqtt".path;
      };
      users.bms = {
        acl = [
          "readwrite bms/#"
          "readwrite homeassistant/#"
          "readwrite zigbee2mqtt/#"
        ];
        passwordFile = config.sops.secrets."mosquitto/passwords/bms".path;
      };
    }];
  };
  networking.firewall.allowedTCPPorts = [ 1883 ];

  services.zigbee2mqtt = {
    enable = true;
    settings = {
      homeassistant.enabled = true;
      mqtt = {
        server = "mqtt://localhost:1883";
        user = "zigbee2mqtt";
        password = "!${config.sops.templates."mosquitto/passwords/zigbee2mqtt.yaml".path} pass";
      };
      serial = {
        port = "/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_6c8c6aafe9a3ef11b4dc4cbd61ce3355-if00-port0";
        adapter = "zstack";
      };
      frontend = {
        port = 3472;
      };
    };
  };
}
