{ pkgs, lib, ... }:

{
  users.users.keith = {
    isNormalUser = true;
    hashedPassword = "**REDACTED**";
    extraGroups = [ "wheel" ]; # Enable `sudo`
    shell = pkgs.zsh;
  };

  home-manager.users.keith = { pkgs, ... }: {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      history.size = 10000;
    };

    home = {
      packages = with pkgs; [
        discord
        spotify
        xidlehook
      ];
    };

    programs.kitty = lib.mkForce {
      enable = true;
      settings = {
	font_family = "family = 'Noto Mono'";
	font_size = 12.0;
	cursor = "#aaaaaa";
	background = "#333333";
	foreground = "#ffffff";
        dynamic_background_opacity = true;
	background_opacity = 0.5;
	background_blur = 5;
      };
    };

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };
    programs.ranger.enable = true;

    systemd.user = {
      enable = true;

      services = {
        discord = {
          Unit = {
            Description = "Start discord on login.";
            # Wait for network to avoid "reconnecting" on startup.
	    # TODO: doesn't seem to work, maybe network service isn't available in user mode?
            After = ["network-online.service"];
	    Wants = ["graphical-session.target"];
          };
          Service = {
            Type = "exec";
            RemainAfterExit = true;
            ExecStart= "${pkgs.discord}/bin/discord --start-minimized";
          };
          Install = {
            WantedBy = ["graphical-session.target"];
          };
        };
      };
    };

    home.stateVersion = "24.11";
  };

  users.users."keith".openssh.authorizedKeys.keys = [
    # Laptop
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFwVu5wURjrYYBrXhuX1L/Bdi0fliXs1ldSI16QEHcjd kcollister@kcollister"
  ];
}
