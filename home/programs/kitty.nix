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

      # Flexoki - stephango.com/flexoki
      background = "#100F0F";
      foreground = "#CECDC3";
      cursor = "#CECDC3";

      color0 = "#100F0F";
      color1 = "#AF3029";
      color2 = "#66800B";
      color3 = "#AD8301";
      color4 = "#205EA6";
      color5 = "#A02F6F";
      color6 = "#24837B";
      color7 = "#878580";

      color8 = "#6F6E69";
      color9 = "#D14D41";
      color10 = "#879A39";
      color11 = "#D0A215";
      color12 = "#4385BE";
      color13 = "#CE5D97";
      color14 = "#3AA99F";
      color15 = "#CECDC3";
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
