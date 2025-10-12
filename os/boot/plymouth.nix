{ pkgs, ... }:
let
  # See https://github.com/adi1090x/plymouth-themes#previews for previews, nice ones are:
  # - lone
  # - rings
  # - splash
  # - darth vader
  # - hexagon dots
  # - hexagon 2
  # - loader 3
  # - spinner
  # - zelda
  theme = "splash";
in
{
  boot = {
    plymouth = {
      enable = true;
      theme = theme;
      themePackages = [
        (pkgs.adi1090x-plymouth-themes.override {
          selected_themes = [ theme ];
        })
      ];
    };

    # Quiet boot
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
  };
}
