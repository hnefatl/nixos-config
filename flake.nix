{
  description = "A very basic flake";

  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      personal-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./machine_configs/personal-laptop.nix
          ./machine_configs/personal-laptop-hardware.nix
        ];
      };
    };
  };
}
