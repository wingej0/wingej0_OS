{ inputs, ... }:
{
  imports = [
    # Adds the wayland.desktopManager.cosmic options
    inputs.cosmic-manager.homeManagerModules.cosmic-manager
    ./appearance.nix
  ];

  # Writes the declared settings with cosmic-ctl on every switch. Settings that
  # aren't declared are left alone, so the Settings app still manages those.
  wayland.desktopManager.cosmic.enable = true;
}
