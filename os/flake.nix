{
  inputs = {
    #nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      # Optional but recommended to limit the size of your system closure.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      lanzaboote,
      sops-nix,
    }:
    {
      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            lanzaboote.nixosModules.lanzaboote
            sops-nix.nixosModules.sops
            ../hosts/laptop/config.nix
            ../hosts/laptop/hardware.nix

            ./base.nix
            ./boot/lanzaboote.nix
            ./configuration.nix

            ./tlp.nix
            ./spotify.nix
            ./swaylock.nix
          ];
        };
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            sops-nix.nixosModules.sops
            ../hosts/desktop/config.nix
            ../hosts/desktop/hardware.nix

            ./base.nix
            ./boot/grub.nix
            ./configuration.nix

            ./sunshine.nix
            ./sshd.nix
            ./spotify.nix
            ./swaylock.nix
          ];
        };
      };
    };
}
