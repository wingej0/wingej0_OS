{ cosmicLib, ... }:
let
  inherit (cosmicLib.cosmic) mkRON;

  spawn = description: command: key: {
    inherit key;
    description = mkRON "optional" description;
    action = mkRON "enum" {
      variant = "Spawn";
      value = [ command ];
    };
  };
in
{
  wayland.desktopManager.cosmic.shortcuts = [
    (spawn "Terminal" "kitty" "Super+Return")
    (spawn "Files" "cosmic-files" "Super+Shift+Return")
  ];
}
