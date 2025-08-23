{ ... }:
{
  programs.feh.enable = true;

  xdg.mimeApps.defaultApplications = {
    "image/*" = [ "feh.desktop" ];
  };
}
