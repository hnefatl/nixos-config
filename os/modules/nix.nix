{ pkgs, ... }:
{
  nix = {
    package = pkgs.nixVersions.stable;

    # Only run daemon operations when there's CPU capacity.
    # Good for my machines, which rarely run at 100% CPU, but could starve
    # nix operations on machines with no spare resources.
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";

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
      trusted-users = [ "@wheel" ];
      auto-optimise-store = true;
      # Required by `nh` at least.
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
}
