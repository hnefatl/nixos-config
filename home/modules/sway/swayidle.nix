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
                timeout = 300; # 5mins
                command = "${lib.getExe pkgs.swaylock-effects} --daemonize";
              }
            ];
      in
      lockIfNotDesktop
      ++ [
        {
          timeout = 310; # 5m10s
          command = "${pkgs.sway}/bin/swaymsg 'output * dpms off'";
          # Reloading mako is a workaround for mako not showing notifications after resume :/
          resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * dpms on' ; ${pkgs.mako}/bin/makoctl reload";
        }
        {
          timeout = 1800; # 30mins
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
  };
}
