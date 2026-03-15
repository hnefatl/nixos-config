{ pkgs, ... }:
{
  # Configure swaylock for all invocations (e.g. manual, lid-close, hibernate, ...).
  programs.swaylock = {
    enable = true;
    settings = {
      show-failed-attempts = true;
      show-keyboard-layout = true;
      indicator-caps-lock = true;
      indicator-radius = 60;
      color = "101010";
    };
  };
}
