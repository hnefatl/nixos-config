{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.greetd = {
    enable = true;
    settings =
      let
        swayCommand = lib.getExe pkgs.sway;
      in
      rec {
        # By default show a nice login UI
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --remember --time --cmd \"${swayCommand}\"";
          user = "greeter";
        };
        # If autologin is enabled, just jump straight in
        initial_session = lib.mkIf config.machine_config.autoLogin {
          command = swayCommand;
          user = "keith";
        };
      };
  };
}
