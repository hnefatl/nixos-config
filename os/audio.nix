{ lib, ... }:
{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    # Pulseaudio compatability layer.
    pulse.enable = true;

    wireplumber = {
      enable = true;
      extraConfig =
        let
          # Shorthand config for audio device renaming.
          # For some reason these have to be separate files per device.
          #
          # Use `wpctl status` and `wpctl inspect <num>` to find properties.
          # This matches on ALSA nodes, not devices, because changing e.g. the PC onboard audio device to "speakers"
          # makes the rear mic port show as "speakers microphone"...
          # Uses regexes to catch the device name part of the sink, regardless of
          #
          # Renaming: https://unix.stackexchange.com/questions/648666/rename-devices-in-pipewire
          # Disabling: https://linuxmusicians.com/viewtopic.php?t=27008
          devices = {
            "pc_speakers" = {
              node = "alsa_output.pci-0000_00_1f.3";
              update = {
                "node.description" = "Speakers";
                "device.form-factor" = "speaker";
                "device.icon-name" = "audio-speakers-symbolic";
              };
            };
            "pc_headphones" = {
              node = "alsa_output.usb-GuangZhou_FiiO_Electronics_Co._Ltd_FiiO_K5_Pro-00";
              update = {
                "node.description" = "Headset";
                "device.form-factor" = "headset";
                "device.icon-name" = "audio-headset-symbolic";
              };
            };
            "pc_monitor" = {
              node = "alsa_output.pci-0000_01_00.1";
              update = {
                "node.disabled" = true;
              };
            };
            "pc_microphone" = {
              node = "alsa_input.pci-0000_00_1f.3";
              update = {
                "node.description" = "Headset";
                "device.form-factor" = "headset";
                "device.icon-name" = "audio-headset-symbolic";
              };
            };
            "pc_webcam" = {
              node = "alsa_input.usb-046d_HD_Pro_Webcam_C920_5DC15EAF-02";
              update = {
                "node.description" = "Webcam";
                "device.form-factor" = "webcam";
                "device.icon-name" = "audio-webcam-symbolic";
              };
            };
          };

          makeDeviceUpdate =
            name: config:
            lib.attrsets.nameValuePair "rename_${name}" {
              "monitor.alsa.rules" = [
                {
                  matches = [
                    {
                      # Match any profile appended to the device name.
                      "node.name" = "~${lib.strings.escapeRegex config.node}\\..*";
                    }
                  ];
                  actions = {
                    update-props = config.update;
                  };
                }
              ];
            };
        in
        lib.attrsets.mapAttrs' makeDeviceUpdate devices;
    };
  };
}
