{
  inputs = {
    self.submodules = true;
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
    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home.url = "path:./../home";
  };

  outputs =
    {
      self,
      nixpkgs,
      lanzaboote,
      sops-nix,
      impermanence,
      nix-topology,
      home,
    }:
    {
      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            lanzaboote.nixosModules.lanzaboote
            sops-nix.nixosModules.sops
            nix-topology.nixosModules.default
            ../hosts/laptop/config.nix

            ./classes/base.nix
            ./classes/graphical.nix
            ./boot/lanzaboote.nix

            ./modules/attic.nix
            ./modules/zfs/zfs.nix
            ./modules/tlp.nix
            ./modules/bluetooth.nix
            ./modules/spotify.nix
            ./modules/fingerprint.nix
            ./modules/wireguard.nix
            ./modules/swaylock.nix
            ./modules/gaming.nix
            ./modules/warthog-nfs.nix
            ./modules/cross-compile-aarch64.nix
          ];
        };
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            lanzaboote.nixosModules.lanzaboote
            sops-nix.nixosModules.sops
            nix-topology.nixosModules.default
            ../hosts/desktop/config.nix

            ./classes/base.nix
            ./classes/graphical.nix
            ./boot/lanzaboote.nix

            ./modules/attic.nix
            ./modules/zfs/zfs.nix
            ./modules/sshd.nix
            ./modules/amd-graphics.nix
            ./modules/sunshine.nix
            ./modules/spotify.nix
            ./modules/swaylock.nix
            ./modules/gaming.nix
            ./modules/obs.nix
            ./modules/warthog-nfs.nix
            ./modules/virtualisation.nix
          ];
        };
        warthog = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            lanzaboote.nixosModules.lanzaboote
            sops-nix.nixosModules.sops
            nix-topology.nixosModules.default
            impermanence.nixosModules.impermanence
            ../hosts/warthog/config.nix

            ./classes/base.nix
            ../os/boot/lanzaboote.nix

            ./modules/zfs/zfs.nix
            ./modules/sshd.nix
            ./modules/tlp.nix
            ./modules/impermanence/impermanence.nix
            ./modules/impermanence/keith.nix
            ../hosts/warthog/modules/services.nix
            ../hosts/warthog/modules/nfs-server.nix
            ../hosts/warthog/modules/smb-server.nix
            ../hosts/warthog/modules/atticd.nix
          ];
          specialArgs = {
            inherit impermanence;
            # This tries to bind the home-manager + nixpkgs versions used by an impermanence setup
            # to the same versions as currently being used on non-impermanence.
            inherit (home.inputs) home-manager;
          };
        };
      };

      # Configure topology diagrams.
      topology."x86_64-linux" = import nix-topology {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [ nix-topology.overlays.default ];
        };
        modules = [
          { nixosConfigurations = self.nixosConfigurations; }
          ./custom-topology.nix
        ];
      };
    };
}
