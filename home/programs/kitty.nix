{ ... }:
{
  programs.kitty = {
    enable = true;

    font = {
      name = "FiraCode Nerd Font";
      size = 10;
    };

    # Adds kitty's shell integration to .zshrc
    shellIntegration.enableZshIntegration = true;

    settings = {
      bold_font = "FiraCode Nerd Font Bold";
      italic_font = "FiraCode Nerd Font Italic";
      bold_italic_font = "FiraCode Nerd Font Bold Italic";

      # Window
      window_padding_width = 10;
      background_opacity = "0.8";
      hide_window_decorations = "titlebar-only";
      draw_minimal_borders = true;
      window_border_width = 0;

      # Cursor
      cursor_shape = "block";
      cursor_blink_interval = 1;

      # Scrollback
      scrollback_lines = 3000;

      # Terminal features
      copy_on_select = true;
      strip_trailing_spaces = "smart";

      # Tabs
      tab_bar_style = "powerline";
      tab_bar_align = "left";

      # Everforest Dark Hard, matches cosmic-term
      background = "#272E33";
      foreground = "#D3C6AA";
      cursor = "#D3C6AA";

      color0 = "#414B50";
      color1 = "#E67E80";
      color2 = "#A7C080";
      color3 = "#DBBC7F";
      color4 = "#7FBBB3";
      color5 = "#D699B6";
      color6 = "#83C092";
      color7 = "#D3C6AA";

      color8 = "#475258";
      color9 = "#E67E80";
      color10 = "#A7C080";
      color11 = "#DBBC7F";
      color12 = "#7FBBB3";
      color13 = "#D699B6";
      color14 = "#83C092";
      color15 = "#D3C6AA";
    };

    keybindings = {
      "ctrl+shift+n" = "new_window";
      "ctrl+shift+t" = "new_tab";
      "ctrl+plus" = "change_font_size all +1.0";
      "ctrl+minus" = "change_font_size all -1.0";
      "ctrl+0" = "change_font_size all 0";
    };
  };
}
