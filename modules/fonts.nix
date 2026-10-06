{ config, pkgs, ... }:
{
    fonts.fontDir.enable = true;
    
    builtins.elem (lib.getName pkg) [ "corefonts" "vistafonts" ];

    fonts.packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        dejavu_fonts
        nerd-fonts.fira-code
        font-awesome
        corefonts
        vista-fonts
    ];
}