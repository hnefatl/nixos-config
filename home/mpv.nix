{ ... }:
{
  programs.mpv = {
    enable = true;
    # `man mpv`
    config = {
      profile = "gpu-hq";
      hwdec = "auto";
      ytdl-format = "bestvideo+bestaudio";
    };
  };

  xdg.mimeApps.defaultApplications = {
    "video/*" = ["mpv.desktop"];
  };
}
