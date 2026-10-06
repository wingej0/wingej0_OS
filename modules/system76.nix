{ config, pkgs, ... }:
{
  hardware.system76.enableAll = true;
  services.power-profiles-daemon.enable = false;
  services.fwupd.enable = true;

  environment.systemPackages = with pkgs; [
    system76-firmware
  ];
}
