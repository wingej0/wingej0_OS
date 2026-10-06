{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    distrobox
  ];

  # Virtualization
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  virtualisation.podman = {
    enable = true;
  };
}
