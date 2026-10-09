from .colors import colors

from libqtile import layout
from libqtile.config import Match

# Define layouts and layout themes
layout_theme = {
    "margin": 8,
    "border_width": 4,
    "border_focus": colors["cyan_dark"],
    "border_normal": colors["bg"],
}

layouts = [
    layout.MonadTall(**layout_theme),
    layout.MonadWide(**layout_theme),
    layout.Max(**layout_theme),
    layout.Spiral(
        main_pane_ratio=0.70,
        ratio=0.52,
        new_client_position="bottom",
        **layout_theme
    ),
]

floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        Match(func=lambda c: c.is_transient_for()),
    ],
    fullscreen_border_width=0,
    border_width=4,
    border_focus=colors["cyan_dark"],
    border_normal=colors["ui3"],
)
