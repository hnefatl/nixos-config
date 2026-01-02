{
  inputs = {
    self.submodules = true;
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    i3blocks-contrib = {
      url = "github:hnefatl/i3blocks-contrib";
      flake = false;
    };
    autoupgrader = {
      url = "github:hnefatl/nixos-autoupgrader";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      firefox-addons,
      i3blocks-contrib,
      autoupgrader,
    }:
    {
      homeConfigurations =
        let
          system = "x86_64-linux";
          pkgs = import nixpkgs {
            inherit system;
            allowUnfree = true;
          };
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            allowUnfree = true;
          };
        in
        {
          "keith@laptop" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ../hosts/laptop/model.nix

              ./classes/standard.nix
              ./modules/firefox.nix
              ./modules/moonlight.nix
              ./modules/signal.nix
            ];
            extraSpecialArgs = {
              inherit inputs;
              inherit pkgs-unstable;
            };
          };
          "keith@desktop" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ../hosts/desktop/model.nix

              ./classes/standard.nix
              ./modules/firefox.nix
              ./modules/ffxiv.nix
              ./modules/vesktop.nix
              ./modules/signal.nix
            ];
            extraSpecialArgs = {
              inherit inputs;
              inherit pkgs-unstable;
            };
          };

          # Users on impermanence-based setups are located in
          # os/modules/impermanence/...
        };
    };
}
