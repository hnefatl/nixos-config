{
  lib,
  home-manager,
  impermanence,
  ...
}:
{
  imports = [ home-manager.nixosModules.home-manager ];

  # This is ~the same as what's defined in `home/flake.nix`, just
  # here because impermanence requires home-manager configs to be
  # defined in the NixOS module, not standalone :/
  home-manager.users.keith = {
    imports = [
      impermanence.homeManagerModules.impermanence
      ../../../hosts/warthog/model.nix
      ../../../home/classes/base.nix
    ];

    # We can't install the home-manager config separately, so make this an alias
    # for installing the OS.
    home.shellAliases."nsh" = lib.mkForce "nso";

    home.persistence."/persist/home/keith" = {
      files = [
        ".zsh_history"
        ".git-credentials"
        ".ssh/id_ed25519"
        ".ssh/id_ed25519.pub"
      ];
      allowOther = true;
    };
  };
}
