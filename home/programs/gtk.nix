{ config, pkgs, inputs, username, ... }:
{
    
    dconf = {
        enable = true;
        settings = {
            "org/virt-manager/virt-manager/connections" = {
                autoconnect = ["qemu:///system"];
                uris = ["qemu:///system"];
            };
        };
    };

    gtk = {
        enable = true;
    
        gtk3 = {
            extraConfig = {
                gtk-application-prefer-dark-theme = 0;
            };
        };

        gtk4 = {
            extraConfig = {
                gtk-application-prefer-dark-theme = 0;
            };
        };

        font = {
            name = "Fira Code Nerd Font";
            size = 11;
        };

        theme = {
            name = "flexoki";
        };

        cursorTheme = {
            name = "FossaCursors";
            size = 24;
        };
    };         
}