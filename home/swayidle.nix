{
  config,
  pkgs,
  lib,
  ...
}:

{
  services.swayidle = {
    enable = true;
    # Lock before sleep in all cases, so that resuming shows a lockscreen.
    events = lib.mkIf (config.machine_config.formFactor == "desktop") [
      {
        event = "before-sleep";
        command = "${lib.getExe pkgs.swaylock-effects} --daemonize";
      }
    ];

    timeouts =
      let
        lockIfNotDesktop =
          if config.machine_config.formFactor == "desktop" then
            [ ]
          else
            [
              {
                timeout = 300;
                command = "${lib.getExe pkgs.swaylock-effects} --daemonize";
              }
            ];
      in
      lockIfNotDesktop
      ++ [
        {
          timeout = 310;
          command = "${pkgs.sway}/bin/swaymsg 'output * dpms off'";
          resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * dpms on'";
        }
        # 30mins
        {
          timeout = 1800;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
  };
}
