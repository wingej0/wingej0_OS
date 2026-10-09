import os

from modules.groups import groups
from modules.hooks import *
from modules.keys import keys, mod, mouse
from modules.layouts import layouts, floating_layout
from modules.screens import screens
from modules.scratchpads import *
from modules.widgets import widget_defaults, extension_defaults

from libqtile.backend.wayland import InputConfig

# Set xdg variables to enable screensharing through xdg-desktop-portal-wlr
os.environ["XDG_SESSION_DESKTOP"] = "qtile:wlroots"
os.environ["XDG_CURRENT_DESKTOP"] = "qtile:wlroots"

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# Configure input devices
wl_input_rules = {
    "type:touchpad": InputConfig(tap=True, natural_scroll=True, dwt=True),
}

# Cursor theme, matches home.pointerCursor in home/system/gtk.nix
wl_xcursor_theme = "Bibata-Modern-Classic"
wl_xcursor_size = 24

# Name of the window manager
wmname = "qtile"
