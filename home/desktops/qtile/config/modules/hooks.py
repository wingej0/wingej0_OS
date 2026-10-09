import subprocess

from libqtile import hook

from . import wallpaper


@hook.subscribe.startup_once
def autostart():
    # Pass the Wayland session to D-Bus and systemd, so portals and
    # D-Bus-activated apps can find the display. This has to finish before
    # the session services start, or they won't see WAYLAND_DISPLAY.
    subprocess.run([
        "dbus-update-activation-environment", "--systemd",
        "WAYLAND_DISPLAY", "XDG_CURRENT_DESKTOP", "XDG_SESSION_DESKTOP", "DISPLAY",
    ])
    # Start polkit, cliphist, dunst, swayidle and kanshi (home/desktops/qtile/default.nix)
    subprocess.Popen(["systemctl", "--user", "start", "qtile-session.target"])
    wallpaper.rotate()


# Give screens added by kanshi or a hotplug the current wallpaper
@hook.subscribe.screens_reconfigured
def screens_changed():
    wallpaper.apply()


@hook.subscribe.shutdown
def stop_session():
    subprocess.run(["systemctl", "--user", "stop", "qtile-session.target"])
