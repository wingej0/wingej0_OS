{ inputs, username, hostname, ... }:
{
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${username} = {
        isNormalUser = true;
        description = "Jeff Winget";
        extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    };

    home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit inputs username hostname; };

        users.${username} = {
            imports = [ ../home/home.nix ];
            programs.home-manager.enable = true;
            home = {
                stateVersion = "26.05";
                username = "${username}";
                homeDirectory = "/home/${username}";
            };
        };
    };
}