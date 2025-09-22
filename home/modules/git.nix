{ config, ... }:
{
  programs.git = {
    enable = true;

    userEmail = "hnefatl@gmail.com";
    userName = "Keith Collister";

    signing = {
      signByDefault = true;
      format = "ssh";
      # Maybe not necessary?
      #key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
    };
  };
}
