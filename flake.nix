{
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
