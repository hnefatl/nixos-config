{ inputs, ... }:
{
  system.autoUpgrade = {
    enable = true;
    flake = "/etc/nixos/os";
    flags = [
      "--print-build-logs"
    ];
    dates = "01:00";
    randomizedDelaySec = "30min";
  };

  # Might need to try
  # https://github.com/firecat53/nixos/blob/38e6b7b410fe6fb3ecb8bada64a2efc88b3e6669/hosts/office/services/nixos.nix#L12
  # if the flake doesn't actually get updated.

  programs.git.config.safe.directory = [
    "/etc/nixos"
    "/etc/nixos/secrets"
  ];
}
