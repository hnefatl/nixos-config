{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        # Consider configuring if starts showing up on weird monitors.
        # output = "..."
        use-bold = true;
        match-counter = true;
        show-actions = true;
        list-executables-in-path = true;
      };
      colors.background = "101010ff";
      # Mod1 is Alt.
      key-bindings = {
        cursor-left = "Left Mod1+h";
        cursor-left-word = "Control+Left Mod1+b";
        cursor-right = "Right Mod1+l";
        cursor-right-word = "Control+Right Mod1+w";
        cursor-home = "Home Mod1+0";
        cursor-end = "End Mod1+Shift+4"; # Assumes GB keyboard layout...
        clipboard-paste = "Control+v Mod1+p";

        next = "Down Mod1+j";
        prev = "Up Mod1+k";
        first = "Mod1+g";
        last = "Mod1+Shift+g";

        # Default keybind conflicts with above.
        custom-10 = "none";
      };
    };
  };
}
