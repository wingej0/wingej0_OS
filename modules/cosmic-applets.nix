{ config, pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
      # cosmic
      cosmic-ext-tweaks
      inputs.cosmic-applets-collection.packages."${pkgs.system}".default
  ];
}
