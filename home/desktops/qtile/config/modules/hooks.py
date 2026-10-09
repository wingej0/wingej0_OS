import subprocess

from libqtile import hook


@hook.subscribe.startup_once
def autostart():
    # Pass the Wayland session to D-Bus and systemd, so portals and
    # D-Bus-activated apps can find the display
    subprocess.Popen([
        "dbus-update-activation-environment", "--systemd",
        "WAYLAND_DISPLAY", "XDG_CURRENT_DESKTOP", "XDG_SESSION_DESKTOP", "DISPLAY",
    ])
