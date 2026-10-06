{ config, pkgs, ... }:
{
  programs.kdeconnect.enable = true;

  environment.systemPackages = with pkgs; [
    telegram-desktop
    discord
    mailspring
    mattermost-desktop
    caprine
    zoom-us
    remmina
  ];
}
