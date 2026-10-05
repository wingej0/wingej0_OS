{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gnome-2048
    en-croissant
    stockfish
    lc0  
    retroarch
  ];
}