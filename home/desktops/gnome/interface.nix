{ ... }:
{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      # Match the dark Flexoki GTK theme in libadwaita apps
      color-scheme = "prefer-dark";
      # Closest built-in accent to Flexoki cyan (#3AA99F)
      accent-color = "teal";
      show-battery-percentage = true;
      enable-hot-corners = false;
      clock-format = "12h";
      clock-show-weekday = true;
      clock-show-date = true;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      workspaces-only-on-primary = true;
    };
  };
}
