{
  pkgs,
  inputs,
  ...
}:
{
  # Enable the COSMIC login manager
  services.displayManager.cosmic-greeter.enable = true;

  # Enable the COSMIC desktop environment
  services.desktopManager.cosmic.enable = true;

  environment.systemPackages = with pkgs; [
    cosmic-ext-tweaks
    inputs.cosmic-applets-collection.packages."${pkgs.stdenv.hostPlatform.system}".default
  ];
}
