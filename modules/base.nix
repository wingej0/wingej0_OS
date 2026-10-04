{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        zsh
        vim
        wget
        git
        gh
        htop
        acpi
        killall
        fzf
        fastfetch
        veracrypt
        gparted
        bibata-cursors
        eza
        yazi
        btop
        bat
        zed-editor
        vscode-fhs
        google-chrome
    ];
}