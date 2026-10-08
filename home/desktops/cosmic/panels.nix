{ lib, cosmicLib, ... }:
let
  inherit (cosmicLib.cosmic) mkRON;

  enum = mkRON "enum";
  plugins = mkRON "optional";
  wings =
    start: end:
    mkRON "optional" (
      mkRON "tuple" [
        start
        end
      ]
    );
in
{
  # Only the identity of each panel and what differs from COSMIC's defaults is
  # declared. autohide is left out: cosmic-manager's option uses the old
  # struct schema, and the default (Never) is what's wanted anyway.
  wayland.desktopManager.cosmic.panels = [
    {
      name = "Panel";
      anchor = enum "Top";
      size = enum "XS";
      margin = 0;
      opacity = 0.7;
      plugins_wings =
        wings
          [
            "dev.cappsy.CosmicExtAppletLogoMenu"
            "com.system76.CosmicAppletWorkspaces"
          ]
          [
            "com.system76.CosmicAppletStatusArea"
            "io.github.cosmic_utils.cosmic-ext-applet-clipboard-manager"
            "dev.dominiccgeh.CosmicAppletEmojiSelector"
            "net.tropicbliss.CosmicExtAppletCaffeine"
            "com.system76.CosmicAppletTiling"
            "com.system76.CosmicAppletAudio"
            "com.system76.CosmicAppletBluetooth"
            "com.system76.CosmicAppletNetwork"
            "com.system76.CosmicAppletBattery"
            "com.system76.CosmicAppletPower"
          ];
      plugins_center = plugins [
        "com.system76.CosmicAppletNotifications"
        "com.system76.CosmicAppletTime"
        "io.github.cosmic_utils.weather-applet"
      ];
    }
    {
      name = "Dock";
      anchor = enum "Left";
      anchor_gap = false;
      expand_to_edges = true;
      size = enum "S";
      margin = 0;
      padding = 0;
      border_radius = 0;
      opacity = 0.7;
      plugins_wings =
        wings
          [
            "com.system76.CosmicAppList"
            "com.system76.CosmicAppletMinimize"
          ]
          [
            "com.system76.CosmicPanelWorkspacesButton"
            "com.system76.CosmicPanelAppButton"
          ];
      plugins_center = plugins [ ];
    }
  ];

  # cosmic-panel reloads its own config; the forced restart only adds flicker.
  home.activation.restartCosmicPanel = lib.mkForce "";
}
