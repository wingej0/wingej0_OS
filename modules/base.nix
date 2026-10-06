{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        vim
        wget
        git
        gh
        htop
        acpi
        killall
        fastfetch
        veracrypt
        gparted
        bibata-cursors
        eza
        yazi
        btop
        bat
        kitty
        ripgrep
        dust
    ];
}