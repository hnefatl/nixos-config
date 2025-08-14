{ ... }:
{
  programs.mpv = {
    enable = true;
    # `man mpv`
    config = {
      profile = "gpu-hq";
      hwdec = "auto";
      gpu-api = "opengl";
      ytdl-format = "bestvideo+bestaudio";
    };
    bindings = {
      # YouTube-style controls
      "j" = "seek -10";
      "k" = "cycle pause";
      "l" = "seek 10";
      "c" = "cycle sub";
      "UP" = "add volume 5";
      "DOWN" = "add volume -5";
    };
  };

  xdg.mimeApps.defaultApplications = {
    "video/*" = ["mpv.desktop"];
  };
}
