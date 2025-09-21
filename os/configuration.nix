# Use e.g. `nixos-option services.fprintd.enable` to query the value of the current config.

{
  config,
  lib,
  pkgs,
  ...
}:

{
  networking.networkmanager.enable = true;
  # Don't wait for network startup, for faster boots: `systemd-analyze`
  # https://old.reddit.com/r/NixOS/comments/vdz86j/how_to_remove_boot_dependency_on_network_for_a
  systemd = {
    services.NetworkManager-wait-online.wantedBy = pkgs.lib.mkForce [ ]; # Normally ["network-online.target"]
  };

  # DO NOT CHANGE: original NixOS version, for backcompat decisions.
  system.stateVersion = "24.11"; # Did you read the comment?
}
