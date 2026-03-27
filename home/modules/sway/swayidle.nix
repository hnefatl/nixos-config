{
  config,
  pkgs,
  lib,
  ...
}:

let
  brightnessctl = lib.getExe pkgs.brightnessctl;
  swaylock = lib.getExe pkgs.swaylock;
  pkill = "${pkgs.procps}/bin/pkill";
  dim-screen = lib.getExe (pkgs.callPackage ../../scripts/dim-screen.nix { });
in
{
  services.swayidle = {
    enable = true;
    # Lock before sleep in all cases, so that resuming shows a lockscreen.
    events = [
      {
        event = "before-sleep";
        command = "${swaylock} --daemonize";
      }
    ];

    timeouts = [
      # These dimmings are undone if the device leaves idle mode, even if on the lockscreen.
      # So the lockscreen is first shown when the screen is dim, but brightens up.
      {
        timeout = 5; # 4m50
        command = "${brightnessctl} -s";
        resumeCommand = "${brightnessctl} -r";
      }
      {
        timeout = 6; # 4m50
        # Dim over <10 seconds, because the script currently takes > the passed time because it's doing naive sleeps.
        command = "${dim-screen} 8";
        resumeCommand = "${pkill} dim-screen";
      }
    ]
    # Desktop is fine to leave unlocked if unattended.
    ++ (lib.optionals (config.machine_config.formFactor != "desktop") [
      {
        timeout = 300; # 5mins
        command = "${swaylock} --daemonize";
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
