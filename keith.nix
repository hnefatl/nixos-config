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


    home.stateVersion = "24.11";
  };

  users.users."keith".openssh.authorizedKeys.keys = [
    # Laptop
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFwVu5wURjrYYBrXhuX1L/Bdi0fliXs1ldSI16QEHcjd kcollister@kcollister"
  ];
}
