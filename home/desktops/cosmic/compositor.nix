{ cosmicLib, ... }:
let
  inherit (cosmicLib.cosmic) mkRON;

  some = mkRON "optional";
  none = mkRON "optional" null;
  enum = mkRON "enum";
in
{
  wayland.desktopManager.cosmic.compositor = {
    autotile = true;
    autotile_behavior = enum "PerWorkspace";

    focus_follows_cursor = true;
    focus_follows_cursor_delay = 125;
    cursor_follows_focus = true;

    # cosmic-manager defaults this to false; keep COSMIC's own default.
    descale_xwayland = enum "fractional";

    input_touchpad = {
      state = enum "Enabled";
      click_method = some (enum "Clickfinger");
      scroll_config = some {
        method = some (enum "TwoFinger");
        natural_scroll = some true;
        scroll_button = none;
        scroll_factor = none;
      };
      tap_config = some {
        enabled = true;
        button_map = some (enum "LeftRightMiddle");
        drag = true;
        drag_lock = false;
      };
    };

    keyboard_config.numlock_state = enum "BootOn";

    xkb_config = {
      rules = "";
      model = "pc104";
      layout = "us";
      variant = "";
      options = some "terminate:ctrl_alt_bksp";
      repeat_delay = 600;
      repeat_rate = 25;
    };
  };
}
