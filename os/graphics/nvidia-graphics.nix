{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf (config.machine_config.instance == "desktop") {
  hardware.graphics = {
    extraPackages = [ pkgs.nvidia-vaapi-driver ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    open = true; # Open firmware since GPU is >=Turing
    modesetting.enable = true;
    nvidiaSettings = true; # Nvidia settings menu `nvidia-settings`.

    # Attempt to use systemd experimental suspend/resume control. Doesn't seem to support hybrid-sleep.
    powerManagement.enable = true;
  };
}
