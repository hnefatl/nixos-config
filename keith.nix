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

    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };

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

    home.stateVersion = "25.05";
  };
}
