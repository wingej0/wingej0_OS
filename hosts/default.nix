{ hostname, ... }:
{
	imports = 
		if hostname == "nixos" then
			[
				./nixos/configuration.nix
				./../modules/system.nix
				./../modules/base.nix
			]
		else
			[];
}
