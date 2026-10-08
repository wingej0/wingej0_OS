{ lib, cosmicLib, ... }:
let
  inherit (cosmicLib.cosmic) mkRON;

  # cosmic-manager wants colors as 0.0-1.0 floats, so convert from hex here.
  # Rounding to the 6 decimals toString prints avoids Nix's
  # "imprecise conversion" warnings.
  hexToRgb =
    hex:
    let
      round6 = x: builtins.floor (x * 1000000 + 0.5) / 1000000.0;
      channel = i: round6 (lib.fromHexString (builtins.substring i 2 (lib.removePrefix "#" hex)) / 255.0);
    in
    {
      red = channel 0;
      green = channel 2;
      blue = channel 4;
    };

  color = hex: mkRON "optional" (hexToRgb hex);
  colorWithAlpha = hex: mkRON "optional" (hexToRgb hex // { alpha = 1.0; });

  radius =
    r:
    mkRON "tuple" [
      r
      r
      r
      r
    ];

  font = family: {
    inherit family;
    weight = mkRON "enum" "Normal";
    stretch = mkRON "enum" "Normal";
    style = mkRON "enum" "Normal";
  };
in
{
  wayland.desktopManager.cosmic.appearance = {
    theme = {
      mode = "dark";

      # Flexoki dark
      dark = {
        accent = color "#3AA99F";
        bg_color = colorWithAlpha "#100F0F";
        neutral_tint = color "#1C1B1A";
        text_tint = color "#CECDC3";

        active_hint = 2;
        gaps = mkRON "tuple" [
          0
          15
        ];
        corner_radii = {
          radius_0 = radius 0.0;
          radius_xs = radius 2.0;
          radius_s = radius 2.0;
          radius_m = radius 2.0;
          radius_l = radius 2.0;
          radius_xl = radius 2.0;
        };
      };
    };

    toolkit = {
      apply_theme_global = true;
      icon_theme = "Papirus-Dark-Maia";
      interface_font = font "FiraCode Nerd Font";
      monospace_font = font "FiraCode Nerd Font Mono";
    };
  };
}
