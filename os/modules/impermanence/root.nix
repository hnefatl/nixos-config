{
  lib,
  home-manager,
  impermanence,
  ...
}:
{
  imports = [ home-manager.nixosModules.home-manager ];

  home-manager.users.root = {
    imports = [ impermanence.homeManagerModules.impermanence ];

    home.persistence."/persist/root" = {
      files = [
        ".zsh_history"
      ];
    };
  };
}
