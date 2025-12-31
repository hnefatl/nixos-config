{ pkgs, lib, ... }:
{
  programs.foot = {
    enable = true;

    # https://codeberg.org/dnkl/foot/src/branch/master/foot.ini
    settings = {
      main = {
        font = "Noto Sans Mono:size=11";
        term = "xterm-256color";
        dpi-aware = "yes";
        gamma-correct-blending = "yes";
      };
      scrollback = {
        lines = "10000";
      };
      colors = {
        alpha = "1.0";
        foreground = "ffffff";
        background = "333333";

        regular0="000000";
        regular1="cc0403";
        regular2="19cb00";
        regular3="cecb00";
        regular4="0d73cc";
        regular5="cb1ed1";
        regular6="0dcdcd";
        regular7="dddddd";
        bright0="767676";
        bright1="f2201f";
        bright2="23fd00";
        bright3="fffd00";
        bright4="1a8fff";
        bright5="fd28ff";
        bright6="14ffff";
        bright7="ffffff";
      };
      mouse = {
        hide-when-typing = "yes";
      };
    };
  };
}
