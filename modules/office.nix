{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    onlyoffice-desktopeditors
    libreoffice
    evince
    anytype
    (callPackage ../pkgs/bibisco.nix { })
    folio
  ];
}
