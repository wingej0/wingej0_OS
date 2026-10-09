from libqtile import bar
from libqtile.config import Screen

from . import wallpaper
from .widgets import init_widgets

# One entry per output; outputs are matched in order, so this doesn't depend
# on connector names. hooks.py rotates the wallpaper; this keeps the
# current one across config reloads.
screens = [
    Screen(
        top=bar.Bar(
            widgets=init_widgets(),
            size=30,
            background="#0000003f",
        ),
        wallpaper=wallpaper.current(),
        wallpaper_mode="fill",
    )
    for _ in range(4)
]
