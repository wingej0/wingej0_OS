import os
import random
from pathlib import Path

from libqtile import qtile

# Same folder as the COSMIC background rotation; changes every 20 minutes
WALLPAPERS = Path.home() / "Pictures" / "wallpapers"
INTERVAL = 20 * 60
IMAGE_TYPES = {".jpg", ".jpeg", ".png", ".webp"}

# Link to the current image. A config reload keeps it, and rofi and gtklock
# use it as their background (home/desktops/qtile/theme.nix).
LINK = Path.home() / ".cache" / "qtile" / "current_wallpaper"


def current():
    return str(LINK.resolve()) if LINK.is_file() else None


def apply():
    path = current()
    if path:
        for screen in qtile.screens:
            screen.set_wallpaper(path, "fill")


def rotate():
    images = [p for p in WALLPAPERS.glob("*") if p.suffix.lower() in IMAGE_TYPES]
    if images:
        LINK.parent.mkdir(parents=True, exist_ok=True)
        # Swap the link in one step, so readers never find it missing
        tmp = LINK.with_name(LINK.name + ".new")
        tmp.unlink(missing_ok=True)
        tmp.symlink_to(random.choice(images))
        os.replace(tmp, LINK)
        apply()
    qtile.call_later(INTERVAL, rotate)
