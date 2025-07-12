{ config, lib, pkgs, ... }:

{
  services.greetd = {
    enable = true;
    settings = let
      swayCommand = "${pkgs.sway}/bin/sway" + (if config.machine_config.instance == "desktop" then " --unsupported-gpu" else "");
    in rec {
      # By default show a nice login UI
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --time --cmd ${swayCommand}";
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

