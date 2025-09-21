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
      };
    };
}
