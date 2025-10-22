{ pkgs, lib, ... }:
{
  imports = [
    ./model.nix
    ./hardware.nix
    ./filesystems.nix
    ./networking.nix
  ];

  # TODO: remove once NixOS selects a new LTS kernel as default (pkgs.linuxPackages.kernel.version is an LTS release).
  # Personal laptop's wifi chip driver has a bug preventing suspend/hibernate in currently-stable 6.12.
  # The chosen kernel version may need to be bumped to a more recent kernel if it goes out of support before the next LTS release.
  boot.kernelPackages = lib.mkIf (lib.versionOlder pkgs.linuxPackages.kernel.version "6.13") pkgs.linuxPackages_6_16;

  # DO NOT CHANGE: original NixOS version, for backcompat decisions.
  system.stateVersion = "24.11"; # Did you read the comment?
}
