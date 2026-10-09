import os
import random
from pathlib import Path

from libqtile import qtile

# Same folder as the COSMIC background rotation; changes every 20 minutes
WALLPAPERS = Path.home() / "Pictures" / "wallpapers"
INTERVAL = 20 * 60
IMAGE_TYPES = {".jpg", ".jpeg", ".png", ".webp"}

# Each screen gets its own image, linked from wallpaper-0, wallpaper-1, ...
# A config reload keeps them. current_wallpaper follows the first screen's,
# and rofi and swaylock use it as their background (home/desktops/qtile/theme.nix).
CACHE = Path.home() / ".cache" / "qtile"
LINK = CACHE / "current_wallpaper"


def screen_link(index):
    return CACHE / f"wallpaper-{index}"


def images():
    return [p for p in WALLPAPERS.glob("*") if p.suffix.lower() in IMAGE_TYPES]


def point(link, target):
    # Swap the link in one step, so readers never find it missing
    link.parent.mkdir(parents=True, exist_ok=True)
    tmp = link.with_name(link.name + ".new")
    tmp.unlink(missing_ok=True)
    tmp.symlink_to(target)
    os.replace(tmp, link)


def set_screen(index, image):
    point(screen_link(index), image)
    if index == 0:
        point(LINK, image)


def current(index=0):
    link = screen_link(index)
    return str(link.resolve()) if link.is_file() else None


def apply():
    for index, screen in enumerate(qtile.screens):
        # A screen that's new since the last rotation gets an image now
        if current(index) is None:
            choices = images()
            if not choices:
                continue
            set_screen(index, random.choice(choices))
        screen.set_wallpaper(current(index), "fill")


def rotate():
    choices = images()
    if choices:
        count = len(qtile.screens)
        # Different images on every screen, unless there aren't enough
        picks = random.sample(choices, min(count, len(choices)))
        picks += random.choices(choices, k=count - len(picks))
        for index, image in enumerate(picks):
            set_screen(index, image)
        apply()

    # The timer is kept on the qtile object, which outlives config reloads,
    # so starting a new rotation always replaces the old one
    old = getattr(qtile, "wallpaper_timer", None)
    if old is not None:
        old.cancel()
    qtile.wallpaper_timer = qtile.call_later(INTERVAL, rotate)
