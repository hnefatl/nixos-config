{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    # https://ghostty.org/docs/config/reference
    settings = {
      font-family = "Noto";
      font-style = "Mono";
      font-size = 12.0;
      theme = "kdefault";
      # TODO: switch to unstable ghostty to support this.
      # Copy terminfo to hosts on first SSH: fallback to xterm-256color if not possible.
      #shell-integration-features = "ssh-terminfo,ssh-env";
    };
    # https://ghostty.org/docs/features/theme#authoring-a-custom-theme
    # This theme based on Kitty.
    themes = {
      "kdefault" = {
        foreground = "#ffffff";
        background = "#333333";
        selection-foreground = "#000000";
        selection-background = "#fffacd";
        cursor-color = "#aaaaaa";
        cursor-text = "#111111";
        palette = [
          # black
          "0=#000000"
          "8=#767676"
          # red
          "1=#cc0403"
          "9=#f2201f"
          # green
          "2=#19cb00"
          "10=#23fd00"
          # yellow
          "3=#cecb00"
          "11=#fffd00"
          # blue
          "4=#0d73cc"
          "12=#1a8fff"
          # magenta
          "5=#cb1ed1"
          "13=#fd28ff"
          # cyan
          "6=#0dcdcd"
          "14=#14ffff"
          # white
          "7=#dddddd"
          "15=#ffffff"
        ];
      };
    };
  };
}
