{ ... }:
{
  # Only settings that differ from each applet's defaults are declared.
  wayland.desktopManager.cosmic = {
    # Apps pinned to the dock
    applets.app-list.settings.favorites = [
      "firefox"
      "google-chrome"
      "Mailspring"
      "chrome-pommaclcbfghclhalboakcipcmmndhcj-Profile_2"
      "org.telegram.desktop"
      "org.kde.kdeconnect.sms"
      "caprine"
      "chrome-kjbdgfilnfhdoflbpgamdcdgpehopbep-Profile_2"
      "anytype"
      "dev.zed.Zed"
      "kitty"
      "kooha"
      "com.obsproject.Studio"
      "sidra"
      "com.system76.CosmicSettings"
      "com.system76.CosmicFiles"
    ];

    # cosmic-manager has no modules for these applets.
    configFile = {
      "com.system76.CosmicAppletBattery" = {
        version = 1;
        entries.show_percentage = true;
      };

      "dev.cappsy.CosmicExtAppletLogoMenu" = {
        version = 1;
        entries.logo = "Cosmic";
      };

      "io.github.cosmic_utils.weather-applet" = {
        version = 1;
        entries = {
          use_fahrenheit = true;
          use_ip_location = true;
        };
      };
    };
  };
}
