{ hostname, ... }:
{
	imports = [
		./darter-pro/configuration.nix
		./modules/system76.nix
		./modules/users.nix
		./modules/fonts.nix
		./modules/nordvpn.nix
		./modules/programs.nix
		./modules/shells.nix
		./modules/development.nix
		./modules/virtualization.nix
	];
}
