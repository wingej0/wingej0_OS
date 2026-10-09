import random
from pathlib import Path

from libqtile import qtile

# Same folder and interval as the COSMIC background rotation
WALLPAPERS = Path.home() / "Pictures" / "wallpapers"
INTERVAL = 300
IMAGE_TYPES = {".jpg", ".jpeg", ".png", ".webp"}

# Remembers the current image, so a config reload keeps it
STATE = Path.home() / ".cache" / "qtile" / "wallpaper"


def current():
    try:
        path = STATE.read_text().strip()
    except OSError:
        return None
    return path if Path(path).is_file() else None


def apply():
    path = current()
    if path:
        for screen in qtile.screens:
            screen.set_wallpaper(path, "fill")


def rotate():
    images = [p for p in WALLPAPERS.glob("*") if p.suffix.lower() in IMAGE_TYPES]
    if images:
        STATE.parent.mkdir(parents=True, exist_ok=True)
        STATE.write_text(str(random.choice(images)))
        apply()
    qtile.call_later(INTERVAL, rotate)
