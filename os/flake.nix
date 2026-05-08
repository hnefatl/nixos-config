{
  inputs = {
    self.submodules = true;
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";
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
    camera-backup.url = "github:hnefatl/camera-backup";
    autoupgrade = {
      url = "github:hnefatl/nixos-autoupgrader";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home.url = "path:./../home";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      lanzaboote,
      sops-nix,
      impermanence,
      nix-topology,
      camera-backup,
      autoupgrade,
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
            autoupgrade.nixosModules.nixos-autoupgrade
            ../hosts/laptop/config.nix

            ./classes/base.nix
            ./classes/graphical.nix
            ./boot/lanzaboote.nix

            ./modules/zfs/zfs.nix
            ./modules/tlp.nix
            ./modules/bluetooth.nix
            ./modules/spotify.nix
            ./modules/fingerprint.nix
            # TODO: re-enable once network is more stable.
            #./modules/wireguard.nix
            ./modules/swaylock.nix
            ./modules/gaming.nix
            ./modules/warthog-nfs.nix
            ./modules/cross-compile-aarch64.nix
            ./modules/photography.nix
            ./modules/monitoring/prometheus-exporter.nix
          ];
          specialArgs = { inherit inputs; };
        };
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            lanzaboote.nixosModules.lanzaboote
            sops-nix.nixosModules.sops
            nix-topology.nixosModules.default
            autoupgrade.nixosModules.nixos-autoupgrade
            ../hosts/desktop/config.nix

            ./classes/base.nix
            ./classes/graphical.nix
            ./boot/lanzaboote.nix

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
            ./modules/cross-compile-aarch64.nix
            ./modules/photography.nix
            ./modules/monitoring/prometheus-exporter.nix
          ];
          specialArgs = { inherit inputs; };
        };
        warthog = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            lanzaboote.nixosModules.lanzaboote
            sops-nix.nixosModules.sops
            nix-topology.nixosModules.default
            autoupgrade.nixosModules.nixos-autoupgrade
            impermanence.nixosModules.impermanence
            ../hosts/warthog/config.nix

            ./classes/base.nix
            ../os/boot/lanzaboote.nix

            ./modules/zfs/zfs.nix
            ./modules/sshd.nix
            ./modules/tlp.nix
            ./modules/impermanence/impermanence.nix
            ./modules/impermanence/keith.nix
            ./modules/monitoring/prometheus-exporter.nix
            ../hosts/warthog/modules/camera-backup-server.nix
            ../hosts/warthog/modules/services.nix
            ../hosts/warthog/modules/nfs-server.nix
            ../hosts/warthog/modules/smb-server.nix
            ../hosts/warthog/modules/prometheus-server.nix
            ../hosts/warthog/modules/authelia/authelia.nix
            ../hosts/warthog/modules/caddy/caddy.nix
          ];
          specialArgs = {
            # Inputs for warthog are this flake's input plus the inputs to the home flake.
            # Attributes in this flake's inputs are prioritised, to try and minimise
            # version skew.
            inputs = home.inputs // inputs;
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
