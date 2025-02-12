{ config, pkgs, ... }:
{
    imports = [
        # # Program Configs
        ./programs/fastfetch.nix
        ./programs/kitty.nix
        ./programs/zsh.nix
        ./programs/gtk.nix
    ];

    home.file = {
        # # Source dotfiles to .config
        # ".config/dunst".source = ./configs/dunst;
        # ".config/picom".source = ./configs/picom;
        # ".config/qtile".source = ./configs/qtile;
        # ".config/rofi".source = ./configs/rofi;
        # ".config/swappy".source = ./configs/swappy;
        # ".config/swaylock".source = ./configs/swaylock;
        # ".config/wallust".source = ./configs/wallust;
        # ".config/wlogout".source = ./configs/wlogout;
    };

    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "24.11"; # Please read the comment before changing.
}