{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        vim
        wget
        git
        htop
        acpi
        killall
        veracrypt
        gparted
        eza
        yazi
        btop
        bat
        ripgrep
        dust
    ];
}