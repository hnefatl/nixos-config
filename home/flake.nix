{
  inputs = {
    self.submodules = true;
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      firefox-addons,
    }:
    {
      homeConfigurations =
        let
          system = "x86_64-linux";
          pkgs = import nixpkgs {
            inherit system;
            allowUnfree = true;
          };
          firefox-packages = (pkgs.callPackage firefox-addons { });
        in
        {
          "keith@laptop" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ../hosts/laptop/model.nix

              ./classes/standard.nix
              ./modules/firefox.nix
              ./modules/moonlight.nix
            ];
            extraSpecialArgs = { inherit firefox-addons; };
          };
          "keith@desktop" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ../hosts/desktop/model.nix

              ./classes/standard.nix
              ./modules/firefox.nix
              ./modules/obs.nix
            ];
            extraSpecialArgs = { inherit firefox-addons; };
          };
          # Deliberately not using real user+hostname - select this explicitly on the command line
          # like `nh home switch ~/nixos-config/home --configuration=keith@corp-laptop`.
          "keith@corp-laptop" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ../hosts/corp-laptop/model.nix

              ./classes/standard.nix
            ];
          };

          # Users on impermanence-based setups are located in
          # os/modules/impermanence/...
        };
    };
}
