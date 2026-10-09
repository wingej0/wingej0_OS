# The Qtile setup, file by file

This explains how Qtile is put together in this repo: what each file does, how
the files connect, and what happens from login to a running desktop. It's
written for someone who knows Qtile's Python config already (you wrote the old
one by hand) but wants to see how the Nix side wraps around it.

## The big picture

There are three layers:

1. **NixOS (system)**: `modules/desktops/qtile.nix`. Installs Qtile, the login
   screen, the portals and the system-wide pieces that need root (PAM, Thunar's
   services, and so on).
2. **Home Manager (your user)**: `home/desktops/qtile/*.nix`. Writes your
   dotfiles (rofi, dunst, swaylock, wlogout, swappy), defines the user services
   that run alongside Qtile, and installs the helper scripts.
3. **Qtile's own Python config**: `home/desktops/qtile/config/`. This is the
   part that's closest to what you wrote before: keys, groups, layouts, the bar.

The Python config is **not** copied into the Nix store. `~/.config/qtile` is a
symlink straight to `~/.dotfiles/home/desktops/qtile/config`, so you can edit
the Python and press **Super+Shift+r** to reload, with no rebuild. Everything in
the `.nix` files does need a `sudo nixos-rebuild switch --flake .#darter-pro`.

### How the desktop gets picked

`flake.nix` passes `desktop = "qtile";` to the whole configuration. Two tiny
files use it:

- `modules/desktops/default.nix` imports `./${desktop}.nix`, so `qtile.nix`.
- `home/desktops/default.nix` imports `./${desktop}`, so the `qtile/` folder
  (which means `home/desktops/qtile/default.nix`).

Change that one word to `"cosmic"` or `"gnome"` and the other desktop is built
instead. Only one desktop is in the system at a time.

### What happens when you log in

1. **greetd + tuigreet** show the text login screen and start the Qtile Wayland
   session.
2. Qtile loads `~/.config/qtile/config.py` (the symlinked repo folder).
3. `config.py` sets `XDG_CURRENT_DESKTOP=qtile:wlroots`, then imports the
   modules. Building `screens` creates four bars.
4. Qtile fires its `startup_once` hook (`modules/hooks.py`), which:
   - pushes `WAYLAND_DISPLAY` and friends into D-Bus and systemd, so services
     started from now on can find the display;
   - starts `qtile-session.target`, which pulls in all the user services:
     kanshi, dunst, swayidle, polkit agent, cliphist;
   - starts the wallpaper rotation.
5. **kanshi** sees which monitors are connected and applies the `docked` or
   `undocked` layout. Qtile notices the screen change, fires
   `screens_reconfigured`, and the hook re-applies the wallpaper.
6. When you exit Qtile, the `shutdown` hook stops `qtile-session.target`, which
   stops those services again.

---

## System layer

### `modules/desktops/qtile.nix`

Everything here needs root, which is why it lives in the NixOS module rather
than Home Manager.

- **`services.xserver.windowManager.qtile`**: installs Qtile and registers its
  session. Despite the `xserver` in the name, this also provides the Wayland
  session. `extraPackages` adds **qtile-extras** to Qtile's Python, which is
  where the bar's `RectDecoration` pills and some widgets come from.
- **`services.greetd`**: the login manager. It runs **tuigreet**, a text-mode
  greeter. `--remember` and `--remember-user-session` mean it pre-fills your
  username and last session. `--sessions` points it at the Wayland session list
  only, so the X11 Qtile session doesn't show up.
- **`systemd.services.greetd.serviceConfig`**: `Type = "idle"` and the `TTY*`
  options stop boot messages from printing over the greeter.
- **`security.pam.services.greetd.enableGnomeKeyring`**: unlocks GNOME Keyring
  with your login password. Mailspring and Mattermost store credentials there.
- **`security.pam.services.swaylock = { }`**: creates `/etc/pam.d/swaylock`.
  Without it, swaylock can't check your password and you can't unlock.
- **Thunar** (`programs.thunar`) plus `tumbler` (thumbnails), `gvfs` (trash,
  network shares, phones) and `udisks2` (mounting USB drives).
- **`programs.xwayland`**: runs X11-only apps inside the Wayland session.
- **`programs.dconf`**: needed so Home Manager's `dconf.settings` (dark mode,
  accent colour) can be stored.
- **`xdg.portal`**: the desktop portals. Apps (especially Flatpaks, Electron
  and browsers) don't talk to the compositor directly for things like file
  pickers, screen sharing or "is dark mode on?". They ask
  `xdg-desktop-portal`, which forwards each question to a backend. Which
  backend answers which question is set per desktop. Since `config.py` sets
  `XDG_CURRENT_DESKTOP=qtile:wlroots`, the portal reads the `config.qtile`
  section:
  - `default = [ "gtk" ]`: file pickers and most other things go to the GTK
    backend.
  - `ScreenCast` and `Screenshot` go to **wlr**, the backend that works with
    wlroots compositors like Qtile. This is what makes screen sharing work.
  - `Settings` go first to **accent** (below), then to **gnome**. The GNOME
    backend runs in "settings only" mode here: it reads dark mode from dconf.
    The GTK backend can't provide an accent colour at all, which is why these
    two are in front of it.
- **`NIXOS_OZONE_WL = "1"`**: tells Electron apps (VS Code, Mailspring and so
  on) to run as native Wayland apps instead of through XWayland.
- **`environment.systemPackages`**: command-line tools the config calls:
  `rofi`, `wlogout`, `wl-clipboard` (`wl-copy`), `wlr-randr` (lists monitors),
  `wdisplays` (graphical monitor arranger), `brightnessctl`, `playerctl`,
  `pavucontrol`, `libnotify` (`notify-send`).

### `modules/desktops/qtile-accent-portal.nix`

This is a small portal backend made just for this setup. Mailspring takes its
theme colour from Electron's `systemPreferences.getAccentColor()`, which on
Linux asks the portal for `org.freedesktop.appearance` → `accent-color`. The
GNOME backend only offers GNOME's named accents (its "teal" isn't Flexoki
cyan), so this file provides the exact colour.

- It's a Nix function that takes `accent` (a hex colour). `qtile.nix` passes
  `cyan` from `home/desktops/qtile/colors.nix`, so if you change the palette
  the accent follows after a rebuild.
- `channel` converts the hex colour to the three 0–1 numbers the portal
  expects.
- The Python script (PyGObject) claims the D-Bus name
  `org.freedesktop.impl.portal.desktop.accent` and answers `Read` and `ReadAll`
  for that one setting. For anything else it returns "not found", and the
  portal moves on to the GNOME backend.
- The `runCommand` at the bottom packages it: a wrapper script, a
  `accent.portal` file (tells the portal "I handle Settings"), and a D-Bus
  `.service` file so it starts on demand the first time someone asks.

---

## Home Manager layer

### `home/desktops/qtile/default.nix`

The entry point for your user's Qtile config. It imports `scripts.nix` and
`theme.nix`, then:

- **`xdg.configFile."qtile".source = mkOutOfStoreSymlink …`**: this is the
  live-editing link. `mkOutOfStoreSymlink` makes `~/.config/qtile` point at the
  repo folder itself, not a read-only copy in `/nix/store`. The comment shows
  the one-line change if you'd rather pin it in the store (then edits need a
  rebuild, but the config can't drift from what's committed).
- **`systemd.user.targets.qtile-session`**: a systemd "target" is just a named
  group of services. Many Home Manager services (dunst, kanshi, swayidle and so
  on) are set to start with `graphical-session.target`. Full desktops like
  GNOME start that target for you; Qtile doesn't. So this defines
  `qtile-session.target`, which `BindsTo` `graphical-session.target`. Starting
  it (from the hook) starts the graphical session and all its services;
  stopping it stops them.
- **`services.kanshi`**: automatic monitor layouts. kanshi watches which
  monitors are connected and applies the first profile whose outputs all
  match.
  - `docked`: laptop screen off, the two MSI monitors side by side at y = 0,
    the ASM portable monitor centred underneath (x = 960, y = 1080).
  - `undocked`: only `eDP-1` (the laptop panel).
  - Monitors are matched by make, model and serial number, not by connector
    name, because DisplayLink's `DP-5`/`DP-6`/`DP-7` names can change between
    boots. Run `wlr-randr` to see the names kanshi matches against.
- **`services.polkit-gnome`**: the little dialog that asks for your password
  when an app needs admin rights.
- **`services.cliphist`** with `allowImages`: records everything you copy
  (text and images) so `qtile-clipboard` can show the history.
- **`services.dunst`**: notifications. Styling is in `theme.nix`.
- **`services.swayidle`**: listens for two events and runs swaylock for both:
  - `before-sleep`: just before suspend or hibernate. swayidle runs with `-w`,
    so it waits for swaylock to finish locking before letting the system
    sleep. Your screen is never visible on resume.
  - `lock`: when anything runs `loginctl lock-session` (Super+Escape, or Lock
    in the power menu).
  - `swaylock -f` forks into the background once the screen is locked.

### `home/desktops/qtile/colors.nix`

The Flexoki dark palette as a Nix attribute set. It's the same palette as
`config/modules/colors.py`, but Nix can't read a Python file, so the colours
exist twice. **If you change a colour, change it in both files.** The Nix copy
is used by `theme.nix` (rofi, dunst, swaylock, wlogout) and the accent portal;
the Python copy by the bar and window borders.

Names: `bg`, `bg2`, `ui`…`ui3` are the dark base tones from darkest to
lightest; `tx3`, `tx2`, `tx` are text from dimmest to brightest; the eight
accents come in a lighter "400" (`cyan`) and a darker "600" (`cyan_dark`)
shade.

### `home/desktops/qtile/scripts.nix`

Four shell scripts, each built with `pkgs.writeShellApplication`. That helper
does three useful things: it puts the listed `runtimeInputs` on the script's
`PATH` (so it doesn't matter what's installed globally), runs `shellcheck` on
the script at build time, and adds `set -euo pipefail`. Each one ends up on
your `PATH` by name.

- **`qtile-clipboard`** (Super+v, Super+Shift+v, the bar's clipboard icon):
  pipes `cliphist list` into a rofi menu. No argument: decode the chosen entry
  and `wl-copy` it back onto the clipboard. `d`: delete the chosen entry. `w`:
  wipe the whole history after a Clear/Cancel prompt.
- **`qtile-screenshot`** (Print, the bar's camera icon): asks "Selected area"
  or "Fullscreen (delay 3 sec)". Area uses `slurp` to drag a rectangle; both
  capture with `grim` and pipe the image straight into **swappy** for
  annotating and saving.
- **`qtile-gif-recorder`** (Super+Print): first press, drag an area with
  `slurp` and `wf-recorder` records it to a temporary MP4. Second press sends
  `SIGINT` to `wf-recorder` to stop it. Then a `zenity` save dialog asks where
  to save, and two `ffmpeg` passes turn it into a good-looking GIF (first
  builds a colour palette from the whole video, then uses it). `timeout 600`
  stops a forgotten recording after 10 minutes.
- **`qtile-power`** (Super+Shift+p, click the battery text on the bar): on AC
  power it sets the System76 battery charge threshold (Full Charge, Balanced,
  Max Lifespan); on battery it sets the power profile (Battery, Balanced,
  Performance). It uses the system's `system76-power` so it matches the
  running daemon, then sends a notification.

All four use `rofi -dmenu -theme menu`, the small menu theme from `theme.nix`.

### `home/desktops/qtile/theme.nix`

All the look-and-feel config for the programs around Qtile. At the top,
`c = import ./colors.nix`, `font = "FiraCode Nerd Font"`, and `wallpaper`
points at `~/.cache/qtile/current_wallpaper` (a symlink to the first screen's
wallpaper, kept updated by `wallpaper.py`).

- **`rofiCommon`**: rofi styling shared by both rofi themes. Translucent dark
  window (`bg2` with `E6` alpha, about 90% opaque) with a cyan border and
  rounded corners, translucent input bar and buttons (`ui` at `99`, 60%),
  selected entry in `cyan_dark`. Being a Nix string, it's simply concatenated
  in front of each theme.
- **`dconf.settings."org/gnome/desktop/interface"`**: `color-scheme =
  "prefer-dark"` is what libadwaita/GTK4 apps and browsers read (through the
  GNOME portal) to go dark. `accent-color = "teal"` is the closest named GNOME
  accent; the accent portal overrides it for apps that ask the portal.
- **`rofi/config.rasi`**: main rofi config. Modes `drun` (apps) and `run`
  (commands), icons on, mouse hover selects, single click launches. It ends with
  `@theme "launcher"`.
- **`rofi/themes/launcher.rasi`**: the big centred app launcher (Super+space,
  the bar's "Qtile" button). A 900px window split in two: the left
  half shows the current wallpaper behind the search box and the Apps/Run
  buttons; the right half lists results.
- **`rofi/themes/menu.rasi`**: the small 400px menu tucked under the right end
  of the bar, used by the scripts. `dynamic: true` makes it shrink to fit short
  lists.
- **`services.dunst.settings`**: notifications centred under the bar
  (`origin = "top-center"`, `offset = "0x35"` clears the 30px bar), 300px wide,
  rounded with a cyan frame, translucent background. `follow = "keyboard"`
  shows them on the monitor you're working on. Critical notifications get a red
  frame. Left click closes one, middle click runs its action, right click
  closes all.
- **`programs.swaylock`**: the lock screen. It uses `swaylock-effects`, a fork
  of swaylock that adds the clock. Settings: the current wallpaper scaled to
  fill, the time and date inside the ring, and the ring always visible. Ring
  colours tell you what's happening: cyan normally and as you type, orange on
  backspace or Caps Lock, yellow when cleared, blue while checking the
  password, red when it's wrong. `hex` strips the `#` because swaylock wants
  bare `RRGGBB` or `RRGGBBAA`.

  Why swaylock and not gtklock: Qtile gives the keyboard to the lock window on
  whichever monitor it has focused, but gtklock only reads the password on the
  one window that has the password box. With only the dock monitors on, those
  were different monitors and you couldn't unlock. swaylock accepts typing on
  any of its windows. If it ever gets stuck anyway: Ctrl+Alt+F2, log in, `pkill
  -USR1 swaylock`.
- **`programs.wlogout`**: the power menu (click the clock). Six buttons with
  keyboard shortcuts: **l** Lock, **h** Hibernate, **e** Exit Qtile, **s**
  Shutdown, **u** Suspend, **r** Reboot. Suspend and hibernate don't lock
  themselves; swayidle's `before-sleep` does that. The `sleep 1` before exit,
  shutdown and reboot gives wlogout time to close first. The `style` builds the
  CSS: a `runCommand` uses ImageMagick to tint wlogout's white PNG icons cyan,
  then each button gets its icon; the hovered button gets a cyan border and
  label.
- **`swappy/config`**: the screenshot editor. Saves to `~/Pictures/screenshots`
  with a timestamped name; `early_exit = false` keeps it open after saving.

---

## Qtile's Python config: `home/desktops/qtile/config/`

Qtile only reads `config.py`. Everything else is split into `modules/` and
imported. `modules/__init__.py` is empty; it's just what makes `modules` a
Python package so `from modules.keys import …` works. `__pycache__` folders
appear because Python compiles the files on load; `.gitignore` excludes them.

To check the config before reloading (catches syntax errors and bad
arguments): `cd ~/.config/qtile && qtile check -c config.py`.

### `config.py`

The file Qtile loads. It mostly imports the variables Qtile looks for, which
must exist as top-level names here: `groups`, `keys`, `mouse`, `layouts`,
`floating_layout`, `screens`, `widget_defaults`, `extension_defaults`.

- `from modules.hooks import *` and `from modules.scratchpads import *` are
  imported for their side effects: importing `hooks` registers the hook
  functions, and importing `scratchpads` appends the scratchpad group to
  `groups`.
- `XDG_SESSION_DESKTOP` / `XDG_CURRENT_DESKTOP = "qtile:wlroots"`: this tells
  the portal to use the `config.qtile` section from `qtile.nix` (it tries
  each name in turn, `qtile` first). The `wlroots` part is a fallback that
  wlroots-specific tools recognise.
- The general settings: focus follows the mouse, floating windows stay on top,
  `focus_on_window_activation = "smart"` (an app asking for focus only gets it
  if it's on the current group), and `reconfigure_screens = True` (rebuild the
  screens when monitors change, which is what lets kanshi's changes take
  effect).
- `wl_input_rules`: touchpad tap-to-click, natural scrolling, and
  disable-while-typing.
- `wl_xcursor_theme` / `wl_xcursor_size`: the Bibata cursor, matching the
  rest of the system.

### `modules/colors.py`

The Python copy of the Flexoki palette (see `colors.nix`). Imported by
`layouts.py` and `widgets.py`.

### `modules/groups.py`

Fourteen groups (workspaces), named after the keys that switch to them: `1`–`9`,
`0`, `minus`, `equal`, `y`, `u`. Each gets a Font Awesome glyph as its
label (that's what the bar shows) and a starting layout: group 2 starts in
`max`, group 3 in `spiral`, group 5 in `monadwide`, group 6 in `max`, the rest in
`monadtall`. The three lists line up by position, so a new group needs an
entry in each.

### `modules/scratchpads.py`

Adds a hidden `ScratchPad` group with four drop-down windows that slide in at
80% of the screen and hide again on the same key:

- `term`: kitty (Alt+Return)
- `volume`: pavucontrol, slightly transparent (Alt+v)
- `angular` and `notebook`: two more kitty terminals (Super+a, Super+n), kept
  separate so each holds its own session.

### `modules/layouts.py`

`layout_theme` is shared by all layouts: 8px gaps, 4px borders, `cyan_dark`
for the focused window and the background colour for the rest. The four
layouts, cycled with Super+Tab: **MonadTall** (one big window left, a stack
on the right), **MonadWide** (the same, rotated), **Max** (one window at a
time), **Spiral** (each new window takes half of the remaining space).

`floating_layout` lists which windows float automatically: Qtile's defaults
(dialogs, splash screens and so on), a few gitk dialogs, ssh-askpass,
pinentry, and any window that's transient for another (child dialogs).

### `modules/keys.py`

`mod = "mod4"` is the Super key. The bindings, in the order they appear:

| Keys | Action |
| --- | --- |
| Super+Return | kitty |
| Super+Shift+q | exit Qtile |
| Super+f | fullscreen |
| Super+q | close window |
| Super+Ctrl+h/j/k/l or arrows | resize (each binding lists several layout commands; whichever the current layout supports runs) |
| Super+h/j/k/l or arrows | move focus |
| Super+Shift+h/j/k/l or arrows | move the window |
| Super+r | reset sizes |
| Super+Tab | next layout |
| Super+Shift+f | flip MonadTall/MonadWide (main pane to the other side) |
| Super+Shift+space | toggle floating |
| Super+i / o / p | focus monitor 1 / 2 / 3 |
| Super+comma / period | next / previous monitor |
| Super+*group key* | show that group |
| Super+Shift+*group key* | send the window to that group |
| Alt+Return, Alt+v, Super+a, Super+n | scratchpads |
| Alt+Tab, Alt+Shift+Tab | next / previous group |
| Super+Shift+Return | Thunar |
| Super+space | rofi app launcher |
| Super+b, Super+m | Firefox, Mailspring |
| media and brightness keys | `wpctl` volume, `playerctl`, `brightnessctl` |
| Super+Shift+r | reload the config |
| Super+Escape | lock (`loginctl lock-session` → swayidle → swaylock) |
| Super+w | new wallpapers on every screen now (restarts the 20-minute timer) |
| Super+v, Super+Shift+v | clipboard history, delete an entry |
| Print, Super+Print | screenshot, GIF recording |
| Super+Shift+p | power profile / charge threshold |

`mouse` holds Super+left-drag to move a floating window, Super+right-drag to
resize it, and Super+middle-click to raise it. Your old config defined these
but `config.py` never imported `mouse`, so they didn't work; now they do.

Group keys are built by looping over `groups`, so adding a group in
`groups.py` gives it keybindings automatically.

### `modules/screens.py`

Builds four identical `Screen`s, each with a 30px translucent bar at the top
(`#0000003f` is black at 25% opacity). Qtile pairs screens with monitors in
order, so this doesn't care about connector names. Each bar calls
`init_widgets()` separately, because a widget object can only live in one bar.
`wallpaper=wallpaper.current(index)` means a config reload keeps each screen's
wallpaper instead of flashing to none.

### `modules/widgets.py`

The bar. qtile-extras' `RectDecoration` draws the rounded "pills" behind groups
of widgets. With `group=True`, neighbouring widgets that share the same
decoration share one pill.

Helpers at the top:

- `pill(colour)` returns the decoration settings; `dark` (cyan_dark), `light`
  (pale text colour, used with dark text on it) and `accent` (ui2) are the three
  pill styles.
- `gap()` is space between pills; `edge(style)` is padding inside a pill's
  ends; `divider(style)` is a thin separator inside a pill.
- `icon(glyph, style, fg, fontsize)` is a Font Awesome glyph in a `TextBox`.
- `flake_age()` returns "N days" since `flake.lock` was last modified, for
  the flake-age pill. It replaces the old `get_updated.py` script.
- `power_profile()` reads `/sys/class/power_supply/AC/online` and asks
  `system76-power` for the charge threshold (on AC) or power profile (on
  battery), for the bar's battery pill.

`init_widgets()`, left to right:

1. **Qtile** launcher button (click opens rofi).
2. **System**: memory %, CPU %, CPU package temperature (turns red when hot).
3. **Brightness and volume**: scroll on either to change it, click volume to
   mute. Brightness reads `acpi_video0` and changes it through `brightnessctl`.
4. **Layout**: the current layout's icon and name.
5. *(spacer)*
6. **Groups**: the group glyphs, centred. A line under a glyph shows where it's
   displayed: bright cyan on the focused monitor, dark cyan on other monitors.
   Grey glyphs are empty groups; red means urgent.
7. *(spacer)*
8. **Now playing** (MPRIS): title and artist from any media player, scrolling.
9. **Flake age**: days since `~/.dotfiles/flake.lock` last changed, so how
   long since the last `nix flake update`. Checked every 10 minutes. It uses
   the dark grey `accent` pill with light text, like the layout pill.
10. **Battery** with the power profile in brackets; click to change it.
11. **Quick launchers**: Gemini (as a Chrome app), Thunar, clipboard,
    screenshot, then Bluetooth and Wi-Fi status (right-click Wi-Fi for
    `nmtui`).
12. **Clock**: click for the wlogout power menu.

### `modules/hooks.py`

Functions that Qtile calls when something happens:

- **`startup_once`** (first start only, not on reload): runs
  `dbus-update-activation-environment --systemd` so D-Bus and systemd learn
  `WAYLAND_DISPLAY` and the desktop name. It uses `subprocess.run` (wait for
  it) because the services started next need those variables. Then it starts
  `qtile-session.target` (the user services) and kicks off the wallpaper
  rotation.
- **`screens_reconfigured`**: when monitors change (kanshi, plugging in the
  dock), give every screen its wallpaper; new screens get a random one.
- **`shutdown`**: stop `qtile-session.target`, so the services don't keep
  running after you log out.

### `modules/wallpaper.py`

Replaces the old Variety + wallust setup with a few lines of Python. Each
screen gets its own random wallpaper, and they all change together every 20
minutes.

- Every screen has its own symlink in `~/.cache/qtile`: `wallpaper-0`,
  `wallpaper-1`, and so on, in the same order as `qtile.screens`.
  `current_wallpaper` always points at the same image as the first screen.
- `rotate()` picks a different image from `~/Pictures/wallpapers` (the same
  folder COSMIC uses) for each screen with `random.sample`, updates the links,
  and applies them. If there are fewer images than screens, it repeats some.
  Then it schedules itself again in 20 minutes with `qtile.call_later`.
- The timer is stored as `qtile.wallpaper_timer`. The `qtile` object survives
  config reloads, so each new rotation cancels the previous timer and two can
  never run at once.
- `point()` replaces a link in one step (make a new link, then `os.replace` it
  over the old one), so rofi or swaylock never catch it missing.
- `current(index)` returns the image a screen's link points to. `screens.py`
  uses it so a reload keeps every screen's wallpaper.
- `apply()` sets each screen's image. A screen that has no link yet (say you
  just plugged in the dock) gets a random one right away. The
  `screens_reconfigured` hook calls it after monitor changes.

rofi and swaylock read `current_wallpaper`, so the launcher and the lock screen
show the first screen's wallpaper on every monitor.

---

## Common tasks

- **Change a keybinding, a widget, a layout or a group**: edit the Python, run
  `qtile check -c config.py` in `~/.config/qtile`, then Super+Shift+r.
- **Change colours**: edit both `colors.nix` and `config/modules/colors.py`.
  Then rebuild (for rofi, dunst, swaylock, wlogout, the accent) and
  Super+Shift+r (for the bar and borders).
- **Change monitor layouts**: edit `services.kanshi` in `default.nix` and
  rebuild. `wlr-randr` shows each monitor's description and modes.
- **Add a script**: add another `writeShellApplication` in `scripts.nix`, add
  it to `home.packages`, rebuild, then bind it in `keys.py`.
- **Something didn't start**: `systemctl --user status qtile-session.target`
  and `journalctl --user -b`. Qtile's own log is
  `~/.local/share/qtile/qtile.log`.
- **After changing portal config**: `systemctl --user restart
  xdg-desktop-portal`, because logging out doesn't always restart it.
