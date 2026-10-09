{ ... }:
{
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;

      favorite-apps = [
        "firefox.desktop"
        "google-chrome.desktop"
        "Mailspring.desktop"
        "chrome-kjbdgfilnfhdoflbpgamdcdgpehopbep-Profile_2.desktop" # Google Calendar
        "chrome-pommaclcbfghclhalboakcipcmmndhcj-Profile_2.desktop" # Google Chat
        "org.telegram.desktop.desktop"
        "caprine.desktop"
        "Mattermost.desktop"
        "discord.desktop"
        "anytype.desktop"
        "org.remmina.Remmina.desktop"
        "kitty.desktop"
        "code.desktop"
        "dev.zed.Zed.desktop"
        "onlyoffice-desktopeditors.desktop"
        "com.github.phase1geo.annotator.desktop"
        "com.obsproject.Studio.desktop"
        "org.kde.kdenlive.desktop"
        "sidra.desktop"
        "org.gnome.Nautilus.desktop"
      ];

      # Installed in modules/desktops/gnome.nix; `gnome-extensions list` for the IDs
      enabled-extensions = [
        "AlphabeticalAppGrid@stuarthayhurst"
        "appindicatorsupport@rgcjonas.gmail.com"
        "blur-my-shell@aunetx"
        "caffeine@patapon.info"
        "clipboard-indicator@tudmotu.com"
        "dash-to-dock@micxgx.gmail.com"
        "tiling-assistant@leleat-on-github"
      ];
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      multi-monitor = true;
      dock-position = "LEFT";
      dash-max-icon-size = 20;
      hot-keys = false;
      running-indicator-style = "DASHES";
      show-mounts = false;
      show-trash = false;
      transparency-mode = "FIXED";
      background-opacity = 0.8;
      apply-custom-theme = true;
    };

    "org/gnome/shell/extensions/tiling-assistant" = {
      window-gap = 8;
      single-screen-gap = 8;
      maximize-with-gap = true;
      dynamic-keybinding-behavior = 2;
      tile-edit-mode = [ "<Super>g" ];
    };
  };
}
