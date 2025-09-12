{ pkgs, ...}:
{
  # Configure swaylock for all invocations (e.g. manual, lid-close, hibernate, ...).
  programs.swaylock = {
    enable = true;
    # Supports extra features
    package = pkgs.swaylock-effects;
    settings = {
      show-failed-attempts = true;
      show-keyboard-layout = true;
      indicator-caps-lock = true;
      indicator-idle-visible = true;
      color = "101010";
      # Extra settings from the -effects fork.
      clock = true;
      timestr = "%H:%M"; # HH:MM
      datestr = "%F"; # YYYY-MM-DD
      indicator = true;
    };
  };
}