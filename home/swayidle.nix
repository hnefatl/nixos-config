{ pkgs, lib, ... }:

{
  services.swayidle = {
    enable = true;
    # Lock before sleep in all cases, so that resuming shows a lockscreen.
    events = [{ event = "before-sleep"; command = "${lib.getExe pkgs.swaylock} --daemonize"; }];

    # TODO: different behaviour when on AC?
    timeouts = [
      # 5mins
      { timeout = 300; command = "${lib.getExe pkgs.swaylock} --daemonize"; }
      {
        timeout = 300;
        command = "${pkgs.sway}/bin/swaymsg 'output * dpms off'";
        resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * dpms on'";
      }
      # 30mins
      # TODO: enable once sleep/hibernate is working
      #{ timeout = 1800; command = "${pkgs.systemd}/bin/systemctl sleep"; }
    ];
  };
}
