{ pkgs, ... }:
{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Keep the core GNOME apps, but skip the intro tour and help docs
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-user-docs
  ];

  environment.systemPackages = with pkgs; [
    gnome-tweaks

    # Gnome extensions, enabled in home/desktops/gnome/shell.nix
    gnomeExtensions.dash-to-dock
    gnomeExtensions.appindicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.caffeine
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.alphabetical-app-grid
    gnomeExtensions.tiling-assistant
  ];
}
