{
  lib,
  inputs,
  home-manager,
  ...
}:
{
  imports = [ home-manager.nixosModules.home-manager ];

  home-manager.users.root = {
    imports = [ inputs.impermanence.homeManagerModules.impermanence ];

    home.persistence."/persist/root" = {
      files = [
        ".zsh_history"
      ];
    };
  };
}
