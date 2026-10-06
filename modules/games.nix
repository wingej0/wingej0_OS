{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gnome-2048
    en-croissant
    stockfish
    lc0
    retroarch # This will likely need to move to home-manager
  ];
}
