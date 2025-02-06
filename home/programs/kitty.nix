{
  programs.kitty = {
    enable = true;
    font = {
      name = "Fira Code Nerd Font";
      size = 10;
    };

    settings = {
        tab_bar_style = "powerline";
        tab_powerline_style = "round";
        active_tab_background = "#6296BE";
        active_tab_foreground = "#1B1B1B";
        inactive_tab_background = "#BEBEBE";
        inactive_tab_foreground = "#1B1B1B";
        hide_window_decorations = true;
        background_opacity = 0.8;
        window_padding_width = 10;
        confirm_os_window_close = 0;
    };
  };
}