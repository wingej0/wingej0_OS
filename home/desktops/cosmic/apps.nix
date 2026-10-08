{ cosmicLib, ... }:
let
  inherit (cosmicLib.cosmic) mkRON;
in
{
  programs.cosmic-files = {
    enable = true;
    # Already installed system-wide with COSMIC.
    package = null;

    # tab is written as a whole, so every field is required; only show_hidden
    # differs from the defaults.
    settings.tab = {
      folders_first = true;
      icon_sizes = {
        list = 100;
        grid = 100;
      };
      show_hidden = true;
      single_click = false;
      view = mkRON "enum" "List";
    };
  };
}
