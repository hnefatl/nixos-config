{
  imports = [
    ./model.nix
    ./hardware.nix
    ./filesystems.nix
  ];

  # DO NOT CHANGE: original NixOS version, for backcompat decisions.
  system.stateVersion = "24.11"; # Did you read the comment?
}