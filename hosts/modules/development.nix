{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    unixODBC
    unixODBCDrivers.msodbcsql18
    gImageReader
    ventoy-full
  ];

  environment.unixODBCDrivers = with pkgs.unixODBCDrivers; [ msodbcsql18 ];
}