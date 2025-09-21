{ config, pkgs, lib, ... }:
{
  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    extraOptions = lib.mkIf (config.machine_config.instance == "desktop") [ "--unsupported-gpu" ];
    wrapperFeatures.gtk = true;
    config = rec {
      terminal = "kitty";
      defaultWorkspace = "workspace number 1";
      # Set the primary monitor in X11 for xwayland apps. Prevents e.g. games defaulting to wrong screen.
      startup = [
        {
          command = "${lib.getExe pkgs.xorg.xrandr} --output ${config.machine_config.primaryMonitor} --primary";
          always = true;
        }
      ];

      # Cycle around containers in the same workspace.
      # TODO: Still need something like i3-cycle to define "horizontal-only" workspace wrapping (or like tabbed-workspace-direction-only).
      # focus.wrapping = "workspace";

      fonts = {
        names = [ "Noto Sans" ];
        style = "Mono";
        size = "10";
      };

      input = {
        "type:keyboard" = {
          xkb_layout = "gb";
          xkb_options = "caps:escape";
          repeat_delay = "200";
          repeat_rate = "58";
          xkb_numlock = "true";
        };
        "type:touchpad" = {
          tap = "enabled";
          # Disable-while-typing
          dwt = "enabled";
        };
      };
      output."*".adaptive_sync = "true";
      # Desktop screens
      output."LG Electronics LG ULTRAGEAR 102MAMBHL915" = {
        position = "0,0";
      };
      output."Samsung Electric Company LF24T35 H4LRC06671" = {
        position = "2560,0";
        transform = "90";
      };
      # Desk screen
      output."Dell Inc. DELL P2720DC 81WTK0131RMS" = {
        position = "-320,-1440";
      };

      window = {
        border = 2;
        titlebar = false;
        hideEdgeBorders = "--i3 smart";
      };
      gaps.smartBorders = "on";
      focus = {
        mouseWarping = "container";
        followMouse = false;
      };

      bars = [
        {
          position = "top";
          trayOutput = "primary";
          statusCommand = "${pkgs.i3blocks}/bin/i3blocks";
        }
      ];

      keybindings = (import ./keybindings.nix { inherit pkgs lib; });
    };
    extraConfig = ''
      # If a game is focused, disable idle
      for_window [class="steam_app*"] inhibit_idle focus
    '';
  };
}