{ config, pkgs, ... }:
{
    imports = [
        ./system
        ./programs
    ];

    home.file = {
        
    };

    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "26.05"; # Please read the comment before changing.
}