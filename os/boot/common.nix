{ lib, ... }:

{
  boot.loader = {
    timeout = lib.mkDefault 1;
    efi.canTouchEfiVariables = true;
  };
}
