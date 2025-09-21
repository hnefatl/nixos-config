{ pkgs, ... }:
{
  nix = {
    package = pkgs.nixVersions.stable;
    optimise = {
      automatic = true;
      dates = [ "Sat *-*-* 09:00:00" ];
    };
    gc = {
      automatic = true;
      dates = "Sat *-*-* 08:00:00";
      options = "--delete-older-than 30d";
    };
    settings = {
      auto-optimise-store = true;
      # Required by `nh` at least.
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
}