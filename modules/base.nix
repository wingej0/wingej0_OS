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
        veracrypt
        gparted
        bibata-cursors
        eza
        yazi
        btop
        bat
        ripgrep
        dust
    ];
}