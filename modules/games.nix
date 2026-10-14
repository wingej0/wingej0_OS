{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gnome-2048
    en-croissant
    stockfish
    lc0
    dolphin-emu
  ];

  # Lets Dolphin access GameCube controller adapters and Wii Remotes without root
  services.udev.packages = [ pkgs.dolphin-emu ];
}
