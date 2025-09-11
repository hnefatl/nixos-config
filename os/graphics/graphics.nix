{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./nvidia-graphics.nix ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
