{
    description = "NixOS Flake";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
        nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

        home-manager = {
            url = "github:nix-community/home-manager/release-25.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        stylix = {
            url = "github:nix-community/stylix/release-25.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, stylix }: {
        nixosConfigurations.afonso-pc = nixpkgs.lib.nixosSystem {
            modules = [ 
                {
                    nixpkgs.overlays = [
                        (final: prev: {
                             unstable = import nixpkgs-unstable {
                                 inherit prev;
                                 system = prev.system;
                                 config.allowUnfree = false;
                             };
                         })
                    ];
                }
                ./configuration.nix 
                stylix.nixosModules.stylix
                home-manager.nixosModules.home-manager {
                    home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;
                    home-manager.backupFileExtension = "bak";
                    home-manager.users.afonsolage.imports = [ ./home.nix ];
                }
            ];
        };
    };
}
