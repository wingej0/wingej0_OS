{ config, pkgs, ... }:
{
  # Qtile as a standalone Wayland compositor. The package ships both an X11 and
  # a Wayland session; tuigreet only lists the Wayland one.
  services.xserver.windowManager.qtile = {
    enable = true;
    extraPackages = python3Packages: with python3Packages; [ qtile-extras ];
  };

  # Login with tuigreet
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
      user = "greeter";
    };
  };

  # Keep boot messages from drawing over the greeter
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  # Unlock the keyring at login (Mailspring and Mattermost keep credentials there).
  # The qtile module already enables gnome-keyring.
  security.pam.services.greetd.enableGnomeKeyring = true;

  # PAM entry so swaylock (home/desktops/qtile/theme.nix) can unlock
  security.pam.services.swaylock = { };

  # Thunar with its thumbnailer, trash and removable drive support
  programs.thunar.enable = true;
  services.tumbler.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  programs.xwayland.enable = true;
  programs.dconf.enable = true;

  # Portals: wlr for screen sharing and screenshots, gnome for settings, gtk
  # for everything else. Settings ask the accent portal first, which gives
  # Electron apps (Mailspring) the exact Flexoki cyan as their accent; gnome
  # answers the rest from dconf (home/desktops/qtile/theme.nix).
  # XDG_CURRENT_DESKTOP is "qtile:wlroots", so qtile-portals.conf is used.
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      (callPackage ./qtile-accent-portal.nix {
        accent = (import ../../home/desktops/qtile/colors.nix).cyan;
      })
    ];
    config.qtile = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.Settings" = [ "accent" "gnome" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
    };
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    rofi
    wlogout
    wl-clipboard
    wlr-randr
    wdisplays
    brightnessctl
    playerctl
    pavucontrol
    libnotify
  ];
}
