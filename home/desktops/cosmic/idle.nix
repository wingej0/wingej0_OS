{ cosmicLib, ... }:
let
  inherit (cosmicLib.cosmic) mkRON;
in
{
  # Times are in milliseconds; None means never.
  wayland.desktopManager.cosmic.idle = {
    suspend_on_ac_time = mkRON "optional" null;
  };
}
