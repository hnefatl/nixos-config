{ pkgs, lib, ... }:
{
  imports = [
    ./base.nix
    ../modules/sway/sway.nix
    ../modules/sway/swaylock.nix
    ../modules/sway/swayidle.nix
    ../modules/feh.nix
    ../modules/mpv.nix
    ../modules/vscode.nix
    ../modules/fuzzel.nix
    ../modules/discord.nix
    ../modules/gammastep.nix
  ];

  home = {
    packages = with pkgs; [
      spotify
      playerctl
      xidlehook
      i3blocks
      noto-fonts
      noto-fonts-color-emoji
      nerd-fonts.symbols-only
      wireguard-tools
      # Needed for e.g. blueman-applet icon.
      hicolor-icon-theme
      # File explorer
      xfce.thunar
      xfce.tumbler
      ffmpegthumbnailer
    ];

    pointerCursor = {
      enable = true;
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 20;
      # Breaks build for home-manager?
      #sway.enable = true;
    };
  };

  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "Noto Sans Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  programs.kitty = lib.mkForce {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      font_family = "family = 'Noto Mono'";
      font_size = 12.0;
      cursor = "#aaaaaa";
      background = "#333333";
      foreground = "#ffffff";
      # Lose some kitty functionality for much better interop on remote machines w/out kitty installed.
      term = "xterm-256color";
    };
  };

  services.mako = {
    enable = true;
    settings = {
      actions = true;
      markup = true;
      default-timeout = 10000;
      border-size = 0;

      # Profile picture icons are big and distracting.
      "app-name=discord".icons = 0;
      # Similar for calendar. Maybe make smaller in the future since this also affects e.g. chat pfps?
      "app-name=\"Google Chrome\"".icons = 0;

      "urgency=low" = {
        background-color = "#222222";
        text-color = "#888888";
        default-timeout = 5000;
      };
      "urgency=normal" = {
        background-color = "#285577";
        text-color = "#ffffff";
        # Layer over fullscreen apps.
        layer = "overlay";
      };
      "urgency=critical" = {
        background-color = "#900000";
        text-color = "#ffffff";
        default-timeout = 0; # don't timeout
        layer = "overlay";
      };
    };
  };

  xdg.mimeApps.enable = true;
  xdg.portal = {
    enable = true;
    configPackages = [ pkgs.xdg-desktop-portal-wlr ];
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };
}
