{ pkgs-custom, ... }:
{
  # https://github.com/gnuradio/gnuradio/issues/8137
  # currently causes segfaults in the generated flows in GUI mode for 3.10.x gnuradios.
  home.packages = with pkgs-custom; [
    (gnuradio.override {
      extraPackages = with gnuradioPackages; [
        osmosdr
      ];
    })
  ];
}
