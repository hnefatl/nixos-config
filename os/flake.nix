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
    home.url = "path:./../home";
  };

  outputs =
    {
      self,
      nixpkgs,
      lanzaboote,
      sops-nix,
      impermanence,
      home,
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
            ./modules/tlp.nix
            ./modules/msmtp.nix
            ./modules/smartd.nix
            ./modules/impermanence/impermanence.nix
            ./modules/impermanence/keith.nix
            ../hosts/warthog/modules/services.nix
          ];
          specialArgs = {
            inherit impermanence;
            # This tries to bind the home-manager + nixpkgs versions used by an impermanence setup
            # to the same versions as currently being used on non-impermanence.
            inherit (home.inputs) home-manager;
          };
        };
      };
    };
}
