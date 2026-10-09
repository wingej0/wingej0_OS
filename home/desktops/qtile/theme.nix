{ config, lib, pkgs, ... }:
let
  c = import ./colors.nix;
  font = "FiraCode Nerd Font";

  # Kept current by config/modules/wallpaper.py
  wallpaper = "${config.home.homeDirectory}/.cache/qtile/current_wallpaper";

  # Rofi pieces shared by the launcher and the menu. Translucent like dunst.
  rofiCommon = ''
    * {
      background-color: transparent;
      text-color: ${c.tx};
    }

    window {
      border: 3px;
      border-color: ${c.cyan_dark};
      border-radius: 10px;
      background-color: ${c.bg2}E6;
      transparency: "real";
      cursor: "default";
    }

    inputbar {
      spacing: 10px;
      padding: 15px;
      border-radius: 10px;
      background-color: ${c.ui}99;
      children: [ "prompt", "entry" ];
    }

    prompt {
      text-color: ${c.cyan};
    }

    entry {
      cursor: text;
      placeholder: "Search";
      placeholder-color: ${c.tx3};
    }

    listview {
      columns: 1;
      cycle: true;
      scrollbar: false;
      fixed-columns: true;
      spacing: 0px;
      padding: 10px;
      background-color: transparent;
    }

    element {
      padding: 10px;
      margin: 5px;
      border-radius: 10px;
      cursor: pointer;
    }

    element selected.normal,
    element selected.active {
      background-color: ${c.cyan_dark};
    }

    element normal.urgent,
    element selected.urgent {
      text-color: ${c.red};
    }

    element-icon {
      size: 32px;
      cursor: inherit;
    }

    element-text {
      text-color: inherit;
      cursor: inherit;
      vertical-align: 0.5;
    }

    textbox,
    error-message {
      padding: 15px;
      border-radius: 10px;
      background-color: ${c.ui}99;
    }
  '';
in
{
  # Dark mode for libadwaita, GTK4 and Electron apps, which ask the portal
  # for this instead of using the GTK theme (same as home/desktops/gnome)
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    accent-color = "teal";
  };

  # App launcher (Super+space and the bar's Qtile button): search and mode
  # buttons over the wallpaper on the left, results on the right
  xdg.configFile."rofi/config.rasi".text = ''
    configuration {
      modi: "drun,run";
      show-icons: true;
      icon-theme: "${config.gtk.iconTheme.name}";
      display-drun: "Apps";
      display-run: "Run";
      drun-display-format: "{name}";
      hover-select: true;
      me-select-entry: "";
      me-accept-entry: "MousePrimary";
    }

    @theme "launcher"
  '';

  xdg.configFile."rofi/themes/launcher.rasi".text = rofiCommon + ''
    * {
      font: "${font} Bold 12";
    }

    window {
      width: 900px;
      location: center;
      anchor: center;
    }

    mainbox {
      orientation: horizontal;
      background-image: url("${wallpaper}", height);
      children: [ "imagebox", "listbox" ];
    }

    imagebox {
      padding: 18px;
      orientation: vertical;
      children: [ "inputbar", "dummy", "mode-switcher" ];
    }

    listbox {
      spacing: 20px;
      orientation: vertical;
      background-color: ${c.bg2}E6;
      children: [ "message", "listview" ];
    }

    prompt {
      enabled: false;
    }

    mode-switcher {
      spacing: 20px;
    }

    button {
      padding: 10px;
      border-radius: 10px;
      background-color: ${c.ui}99;
      cursor: pointer;
    }

    button selected {
      background-color: ${c.cyan_dark};
    }

    listview {
      lines: 8;
      fixed-height: true;
    }
  '';

  # Small menu under the right end of the bar, for the qtile-* scripts
  # (rofi -dmenu -theme menu). It shrinks to fit short lists.
  xdg.configFile."rofi/themes/menu.rasi".text = rofiCommon + ''
    * {
      font: "${font} Bold 10";
    }

    window {
      width: 400px;
      location: northeast;
      anchor: northeast;
      x-offset: -14px;
      y-offset: 35px;
    }

    mainbox {
      spacing: 0px;
      children: [ "inputbar", "message", "listview" ];
    }

    inputbar {
      border-radius: 10px 10px 0px 0px;
    }

    listview {
      lines: 8;
      dynamic: true;
      fixed-height: false;
    }
  '';

  # Notifications, centered under the bar
  services.dunst.settings = {
    global = {
      follow = "keyboard";
      width = 300;
      height = "(0, 300)";
      origin = "top-center";
      offset = "0x35";
      notification_limit = 20;

      progress_bar = true;
      progress_bar_height = 10;
      progress_bar_frame_width = 1;
      progress_bar_min_width = 150;
      progress_bar_max_width = 300;
      progress_bar_corner_radius = 5;
      highlight = c.cyan;

      indicate_hidden = true;
      separator_height = 2;
      separator_color = "frame";
      padding = 8;
      horizontal_padding = 8;
      text_icon_padding = 8;
      frame_width = 3;
      frame_color = c.cyan_dark;
      corner_radius = 10;
      gap_size = 0;
      sort = true;

      font = "${font} 11";
      line_height = 3;
      markup = "full";
      format = "<b>%s</b>\\n%b";
      alignment = "left";
      vertical_alignment = "center";
      show_age_threshold = 60;
      ellipsize = "middle";
      stack_duplicates = true;
      show_indicators = true;

      enable_recursive_icon_lookup = true;
      icon_theme = config.gtk.iconTheme.name;
      icon_position = "left";
      min_icon_size = 32;
      max_icon_size = 128;

      sticky_history = true;
      history_length = 20;
      browser = "xdg-open";
      always_run_script = true;

      mouse_left_click = "close_current";
      mouse_middle_click = "do_action, close_current";
      mouse_right_click = "close_all";
    };

    urgency_low = {
      background = "${c.bg2}E6";
      foreground = c.tx2;
      frame_color = c.ui3;
      timeout = 6;
    };

    urgency_normal = {
      background = "${c.bg2}E6";
      foreground = c.tx;
      timeout = 6;
    };

    urgency_critical = {
      background = "${c.bg2}E6";
      foreground = c.tx;
      frame_color = c.red;
      timeout = 6;
    };
  };

  # Lock screen over the current wallpaper. swaylock rather than gtklock:
  # Qtile gives keyboard focus to the lock surface on the focused screen,
  # and gtklock only reads the password on its one form window, so with
  # just the dock's monitors typing often went nowhere. swaylock takes keys
  # on any of its surfaces. The -effects fork adds the clock.
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = let hex = lib.removePrefix "#"; in {
      image = wallpaper;
      scaling = "fill";
      clock = true;
      timestr = "%H:%M";
      datestr = "%a %b %-d";
      font = font;
      font-size = 28;
      indicator = true;
      indicator-radius = 110;
      indicator-thickness = 8;
      ignore-empty-password = true;
      show-failed-attempts = true;

      inside-color = "${hex c.bg2}D9";
      inside-clear-color = "${hex c.bg2}D9";
      inside-ver-color = "${hex c.bg2}D9";
      inside-wrong-color = "${hex c.bg2}D9";
      inside-caps-lock-color = "${hex c.bg2}D9";
      ring-color = hex c.cyan_dark;
      ring-clear-color = hex c.yellow;
      ring-ver-color = hex c.blue;
      ring-wrong-color = hex c.red;
      ring-caps-lock-color = hex c.orange;
      key-hl-color = hex c.cyan;
      bs-hl-color = hex c.orange;
      caps-lock-key-hl-color = hex c.cyan;
      caps-lock-bs-hl-color = hex c.orange;
      text-color = hex c.tx;
      text-clear-color = hex c.tx;
      text-ver-color = hex c.tx;
      text-wrong-color = hex c.red;
      text-caps-lock-color = hex c.orange;
      line-color = "00000000";
      line-clear-color = "00000000";
      line-ver-color = "00000000";
      line-wrong-color = "00000000";
      line-caps-lock-color = "00000000";
      separator-color = "00000000";
    };
  };

  # Power menu (the bar's clock). Suspend and hibernate don't lock here:
  # swayidle's before-sleep hook does that.
  programs.wlogout = {
    enable = true;
    layout = [
      {
        label = "lock";
        action = "loginctl lock-session";
        text = "Lock";
        keybind = "l";
      }
      {
        label = "hibernate";
        action = "systemctl hibernate";
        text = "Hibernate";
        keybind = "h";
      }
      {
        label = "logout";
        action = "sleep 1; qtile cmd-obj -o root -f shutdown";
        text = "Exit";
        keybind = "e";
      }
      {
        label = "shutdown";
        action = "sleep 1; systemctl poweroff";
        text = "Shutdown";
        keybind = "s";
      }
      {
        label = "suspend";
        action = "systemctl suspend";
        text = "Suspend";
        keybind = "u";
      }
      {
        label = "reboot";
        action = "sleep 1; systemctl reboot";
        text = "Reboot";
        keybind = "r";
      }
    ];
    style =
      let
        # The package's white icons, tinted cyan (alpha kept)
        icons = pkgs.runCommand "wlogout-icons-cyan" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
          mkdir $out
          for f in ${pkgs.wlogout}/share/wlogout/icons/*.png; do
            magick "$f" -fill "${c.cyan}" -colorize 100 "$out/$(basename "$f")"
          done
        '';
        icon = name: ''
          #${name} {
            background-image: image(url("${icons}/${name}.png"));
          }
        '';
      in
      ''
        * {
          font-family: "${font}", "Font Awesome 7 Free", sans-serif;
          background-image: none;
          transition: 20ms;
        }

        window {
          background-color: alpha(${c.bg}, 0.6);
        }

        button {
          color: ${c.tx};
          font-size: 20px;
          margin: 10px;
          border: 3px solid ${c.ui3};
          border-radius: 20px;
          background-color: alpha(${c.bg2}, 0.85);
          background-repeat: no-repeat;
          background-position: center;
          background-size: 25%;
          box-shadow: 0 4px 8px 0 alpha(${c.bg}, 0.4);
        }

        button:focus,
        button:active,
        button:hover {
          color: ${c.cyan};
          border-color: ${c.cyan_dark};
          background-color: alpha(${c.ui}, 0.9);
        }
      ''
      + lib.concatMapStrings icon [
        "lock"
        "hibernate"
        "logout"
        "shutdown"
        "suspend"
        "reboot"
      ];
  };

  # Screenshot editor opened by qtile-screenshot; its colors come from the
  # GTK theme
  xdg.configFile."swappy/config".text = ''
    [Default]
    save_dir=${config.home.homeDirectory}/Pictures/screenshots
    save_filename_format=screenshot-%Y%m%d-%H%M%S.png
    show_panel=false
    line_size=5
    text_size=20
    text_font=${font}
    paint_mode=brush
    early_exit=false
    fill_shape=false
  '';
}
