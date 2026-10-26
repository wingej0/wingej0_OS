{ config, pkgs, ... }:
{
  hardware.system76.enableAll = true;
  services.power-profiles-daemon.enable = false;
  services.fwupd.enable = true;

  environment.systemPackages = with pkgs; [
    system76-firmware
    # Remap the Launch keyboard's firmware layout (stored on the keyboard)
    system76-keyboard-configurator
  ];
}
