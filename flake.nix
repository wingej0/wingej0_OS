{
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

		 # Home Manager
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		# Sidra Music Player
		sidra = {
			url = "github:wimpysworld/sidra";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { nixpkgs, ... } @ inputs:
	{
		nixosConfigurations = {
			nixos = nixpkgs.lib.nixosSystem {
				specialArgs = {
					inherit inputs;
					username = "wingej0";
					hostname = "nixos";
				};
				modules = [
					./hosts
				];
			};
		};
	};
}
