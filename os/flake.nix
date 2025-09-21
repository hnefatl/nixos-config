{
  inputs = {
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
    impermanence.url = "github:nix-community/impermanence";
    # Could consider importing the home/ flake by path, then referring to home-manager
    # inside it, to ensure the version stays aligned with non-impermanence setups?
    home-manager.url = "github:nix-community/home-manager?ref=release-25.05";
  };

  outputs =
    {
      self,
      nixpkgs,
      lanzaboote,
      sops-nix,
      impermanence,
      home-manager,
    }:
    {
      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            lanzaboote.nixosModules.lanzaboote
            sops-nix.nixosModules.sops
            ../hosts/laptop/config.nix

            ./classes/base.nix
            ./classes/graphical.nix
            ./boot/lanzaboote.nix

            ./modules/tlp.nix
            ./modules/bluetooth.nix
            ./modules/spotify.nix
            ./modules/fingerprint.nix
            ./modules/wireguard.nix
            ./modules/swaylock.nix
            ./modules/gaming.nix
          ];
        };
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            sops-nix.nixosModules.sops
            ../hosts/desktop/config.nix

            ./classes/base.nix
            ./classes/graphical.nix
            ./boot/grub.nix

            ./modules/zfs.nix
            ./modules/sshd.nix
            ./modules/nvidia-graphics.nix
            ./modules/sunshine.nix
            ./modules/spotify.nix
            ./modules/swaylock.nix
            ./modules/gaming.nix
          ];
        };
        warthog = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            sops-nix.nixosModules.sops
            impermanence.nixosModules.impermanence
            ../hosts/warthog/config.nix

            ./classes/base.nix
            ../hosts/warthog/boot.nix

            ./modules/zfs.nix
            ./modules/sshd.nix
            ./modules/impermanence/impermanence.nix
            ./modules/impermanence/keith.nix
            ../hosts/warthog/modules/services.nix
          ];
	  specialArgs = { inherit impermanence home-manager; };
        };
      };
    };
}
