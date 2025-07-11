{
  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      # Optional but recommended to limit the size of your system closure.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, lanzaboote }: {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./boot/lanzaboote.nix
          ./configuration.nix
          ../hosts/laptop.nix
          ../hosts/laptop-hardware.nix
          lanzaboote.nixosModules.lanzaboote
        ];
      };
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./boot/grub.nix
          ./configuration.nix
          ../hosts/desktop.nix
          ../hosts/desktop-hardware.nix
        ];
      };
    };
  };
}
