{
  config,
  pkgs,
  lib,
  ...
}:

let
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
in
{
  services.swayidle = {
    enable = true;
    # Lock before sleep in all cases, so that resuming shows a lockscreen.
    events = [
      {
        event = "before-sleep";
        command = "${lib.getExe pkgs.swaylock-effects} --daemonize";
      }
    ];

    timeouts = [
      # These dimmings are undone if the device leaves idle mode, even if on the lockscreen.
      # So the lockscreen is first shown when the screen is dim, but brightens up.
      {
        timeout = 290; # 4m50s
        command = "${brightnessctl} -s ; ${brightnessctl} set $(($(${brightnessctl} get) / 2))";
        resumeCommand = "${brightnessctl} -r";
      }
      {
        timeout = 295; # 4m55s
        command = "${brightnessctl} set $(($(${brightnessctl} get) / 2))";
      }
    ]
    # Desktop is fine to leave unlocked if unattended.
    ++ (lib.optionals (config.machine_config.formFactor != "desktop") [
      {
        timeout = 300; # 5mins
        command = "${lib.getExe pkgs.swaylock-effects} --daemonize";
      }
    ])
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
