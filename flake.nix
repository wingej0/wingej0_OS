{
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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
