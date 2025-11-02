{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.attic-client ];

  nix.settings = {
    substituters = [
      "https://attic.warthog.keith.collister.xyz/prod"
    ];
    trusted-public-keys = [
      "prod:ZYkl8upOTl/y60/CrTUjQ+8jPtB43QaPv9wwSvOAyxU="
    ];
  };
}
