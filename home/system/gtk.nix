{ pkgs, ... }:
{
    # Cursor theme (replaces environment.d, gtk settings.ini and .Xresources)
    home.pointerCursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
        gtk.enable = true;
        x11.enable = true;
    };

    gtk = {
        enable = true;
    };
}
