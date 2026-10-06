{ config, pkgs, ... }:
{
    # Cursor theme (replaces environment.d, gtk settings.ini and .Xresources)
    home.pointerCursor = {
        enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
        gtk.enable = true;
        x11.enable = true;
    };

    # Also set the cursor through systemd (~/.config/environment.d), so desktops
    # that don't load the shell profile, like COSMIC, still pick it up
    systemd.user.sessionVariables = {
        XCURSOR_THEME = config.home.pointerCursor.name;
        XCURSOR_SIZE = toString config.home.pointerCursor.size;
    };

    gtk = {
        enable = true;
    };
}
