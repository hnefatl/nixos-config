{ pkgs, lib, ... }:
{
  programs.terminator = {
    enable = true;
  };

  # The default home-manager config solution of symlinking fails, because terminator wants r+w access to the file.
  # Instead copy it as a writeable file and stomp it on update.
  home.activation.terminator-config-file =
    let
      config = pkgs.writeText "terminator_config" ''
        [profiles]
          [[default]]
            font = Noto Sans Mono 12
            use_system_font = False

            show_titlebar = False
            scrollbar_position = hidden
            scrollback_infinite = True

            foreground_color = "#FFFFFF"
            background_color = "#333333"
            cursor_color = "#aaaaaa"
            palette = "#000000:#cc0403:#19cb00:#cecb00:#0d73cc:#cb1ed1:#0dcdcd:#dddddd:#767676:#f2201f:#23fd00:#fffd00:#1a8fff:#fd28ff:#14ffff:#ffffff"
      '';
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p $VERBOSE_ARG ~/.config/terminator
      run cp $VERBOSE_ARG ${config} ~/.config/terminator/config
      run chmod $VERBOSE_ARG u+w ~/.config/terminator/config
    '';
}
