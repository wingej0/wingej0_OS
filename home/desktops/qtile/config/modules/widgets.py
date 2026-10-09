import subprocess

from libqtile.lazy import lazy
from qtile_extras import widget
from qtile_extras.widget.decorations import RectDecoration

from .colors import colors

font = "FiraCode Nerd Font"
bold = "FiraCode Nerd Font SemiBold"
icons = "Font Awesome 7 Free Solid"

widget_defaults = dict(
    font=font,
    fontsize=11,
    padding=3,
)
extension_defaults = widget_defaults.copy()


# Rounded pills behind groups of widgets: dark with light text, light with
# dark text, and an accent
def pill(colour):
    return {
        "decorations": [
            RectDecoration(colour=colour, filled=True, radius=10, padding_y=4, group=True)
        ]
    }


dark = pill(colors["ui2"])
light = pill(colors["tx"])
accent = pill(colors["cyan_dark"])


def gap():
    return widget.Spacer(length=10)


def edge(style):
    return widget.Spacer(length=10, **style)


def divider(style):
    return widget.Sep(foreground=colors["bg"], padding=10, size_percent=60, **style)


def icon(glyph, style, fg, fontsize=12, **config):
    return widget.TextBox(text=glyph, font=icons, fontsize=fontsize, foreground=fg, **style, **config)


def power_profile():
    # Charge threshold on AC, power profile on battery (same as qtile-power)
    try:
        with open("/sys/class/power_supply/AC/online") as f:
            on_ac = f.read().strip() == "1"
        if on_ac:
            out = subprocess.check_output(["system76-power", "charge-thresholds"], text=True)
        else:
            out = subprocess.check_output(["system76-power", "profile"], text=True)
    except (OSError, subprocess.CalledProcessError):
        return ""
    for line in out.splitlines():
        if line.startswith(("Profile:", "Power Profile:")):
            value = line.split(":", 1)[1].strip()
            # "Full Charge (full_charge)" -> "Full Charge"
            return value.split(" (")[0]
    return ""


def init_widgets():
    fg_dark = colors["bg"]
    fg_light = colors["tx"]

    return [
        gap(),

        # Launcher
        edge(dark),
        icon("", dark, fg_light, fontsize=14),
        widget.TextBox(
            text="Qtile", font=bold, fontsize=12, foreground=fg_light,
            mouse_callbacks={"Button1": lazy.spawn("rofi -show drun")},
            **dark,
        ),
        edge(dark),
        gap(),

        # System
        edge(light),
        icon("", light, fg_dark),
        widget.Memory(format="{MemPercent:.0f}%", foreground=fg_dark, **light),
        divider(light),
        icon("", light, fg_dark),
        widget.CPU(format="{load_percent:.0f}%", foreground=fg_dark, **light),
        divider(light),
        icon("", light, fg_dark),
        widget.ThermalSensor(tag_sensor="Package id 0", foreground=fg_dark,
                             foreground_alert=colors["red_dark"], **light),
        edge(light),
        gap(),

        # Brightness and volume; scroll to change, click volume to mute
        edge(light),
        icon("", light, fg_dark),
        widget.Backlight(
            backlight_name="acpi_video0", change_command="brightnessctl set {0}%",
            step=5, foreground=fg_dark, **light,
        ),
        divider(light),
        icon("", light, fg_dark),
        widget.PulseVolume(
            foreground=fg_dark, limit_max_volume=True, volume_app="pavucontrol",
            **light,
        ),
        edge(light),
        gap(),

        # Layout
        edge(accent),
        widget.CurrentLayoutIcon(foreground=fg_light, scale=0.5, **accent),
        widget.CurrentLayout(foreground=fg_light, **accent),
        edge(accent),

        widget.Spacer(),

        # Groups
        edge(dark),
        widget.GroupBox(
            font=icons,
            fontsize=11,
            active=fg_light,
            inactive=colors["tx3"],
            borderwidth=2,
            disable_drag=True,
            hide_unused=False,
            highlight_method="line",
            highlight_color=["#00000000", "#00000000"],
            this_current_screen_border=colors["cyan"],
            this_screen_border=colors["tx2"],
            other_current_screen_border=colors["cyan_dark"],
            other_screen_border=colors["ui3"],
            urgent_method="line",
            urgent_border=colors["red"],
            use_mouse_wheel=False,
            **dark,
        ),
        edge(dark),

        widget.Spacer(),

        # Now playing
        widget.Mpris2(
            format="{xesam:title} - {xesam:artist}",
            paused_text=" {track}",
            width=175,
            scroll=True,
            foreground=fg_light,
        ),
        gap(),

        # Battery and power profile; click to change it
        edge(light),
        icon("", light, fg_dark),
        widget.Battery(format="{percent:2.0%}", foreground=fg_dark, update_interval=30, **light),
        widget.GenPollText(
            func=power_profile, fmt="({})", update_interval=30, foreground=fg_dark,
            mouse_callbacks={"Button1": lazy.spawn("qtile-power")},
            **light,
        ),
        edge(light),
        gap(),

        # Quick launchers and connectivity
        edge(light),
        icon("", light, fg_dark,
             mouse_callbacks={"Button1": lazy.spawn("google-chrome-stable --app=https://gemini.google.com")}),
        icon("", light, fg_dark, mouse_callbacks={"Button1": lazy.spawn("thunar")}),
        icon("", light, fg_dark, mouse_callbacks={"Button1": lazy.spawn("qtile-clipboard")}),
        icon("", light, fg_dark, mouse_callbacks={"Button1": lazy.spawn("qtile-screenshot")}),
        widget.Bluetooth(default_text="", font=icons, fontsize=12, foreground=fg_dark, **light),
        widget.WiFiIcon(
            interface="wlp0s20f3", active_colour=fg_dark, foreground=fg_dark, padding_y=9,
            mouse_callbacks={"Button3": lazy.spawn("kitty -e nmtui")},
            **light,
        ),
        edge(light),
        gap(),

        # Clock; click for the power menu
        edge(dark),
        widget.Clock(
            format="%b %d | %I:%M %p", font=bold, fontsize=12, foreground=fg_light,
            mouse_callbacks={"Button1": lazy.spawn("wlogout")},
            **dark,
        ),
        edge(dark),
        gap(),
    ]
