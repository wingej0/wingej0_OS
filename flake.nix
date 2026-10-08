{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Cosmic Applets
    cosmic-applets-collection.url = "github:wingej0/ext-cosmic-applets-flake";

    # Sidra Music Player
    sidra = {
      url = "github:wimpysworld/sidra";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flexoki GTK Theme
    flexoki = {
      url = "github:kepano/flexoki";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
      nixosConfigurations = {
        darter-pro = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
            username = "wingej0";
            hostname = "darter-pro";
          };
          modules = [
            ./hosts
          ];
        };
      };
    };
}
