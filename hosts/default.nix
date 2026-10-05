{ hostname, ... }:
{
	imports = 
		if hostname == "nixos" then
			[
				./nixos/configuration.nix
				./../modules/system.nix
				./../modules/base.nix
				./../modules/ai.nix
				./../modules/browsers.nix
				./../modules/communication.nix
				./../modules/development.nix
				./../modules/fonts.nix
				./../modules/games.nix
			]
		else
			[];
}
