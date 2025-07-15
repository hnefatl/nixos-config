{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }: {
    homeConfigurations = let
      pkgs = import nixpkgs { system = "x86_64-linux"; allowUnfree = true; };
    in {
      "keith@laptop" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./keith.nix
          ../hosts/laptop.nix
        ];
      };
      "keith@desktop" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./keith.nix
          ../hosts/desktop.nix
        ];
      };
      # Deliberately not using real user+hostname - select this explicitly on the command line
      # like `nh home switch ~/nixos-config/home --configuration=keith@corp-laptop`.
      "keith@corp-laptop" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./keith.nix
          ../hosts/corp-laptop.nix
        ];
      };
    };
  };
}

