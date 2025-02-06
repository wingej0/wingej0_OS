{
	inputs = {
		# Nix Packages
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

		# Snaps
		nix-snapd = {
			url = "github:nix-community/nix-snapd";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		# Home Manager
    	home-manager = {
      		url = "github:nix-community/home-manager";
      		inputs.nixpkgs.follows = "nixpkgs";
    	};

		 # Nix User Repository
		nur = {
			url = "github:nix-community/NUR";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		# Cosmic Desktop
		nixos-cosmic = {
			url = "github:lilyinstarlight/nixos-cosmic";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { nixpkgs, ... } @ inputs:
	{
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
