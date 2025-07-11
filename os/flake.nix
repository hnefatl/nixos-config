{
  description = "A very basic flake";

  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ../hosts/laptop.nix
          ../hosts/laptop-hardware.nix
        ];
      };
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ../hosts/desktop.nix
          ../hosts/desktop-hardware.nix
        ];
      };
    };
  };
}
