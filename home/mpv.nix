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
  };

  xdg.mimeApps.defaultApplications = {
    "video/*" = ["mpv.desktop"];
  };
}
