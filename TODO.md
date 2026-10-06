# TODO

## Config

- [ ] **Simplify host selection**: build hosts with a `mkHost` function in `flake.nix`
      (`modules = [ ./hosts/${hostname} ];`), move the module list from `hosts/default.nix`
      into `hosts/<host>/default.nix`, and delete `hosts/default.nix`.
      If renaming the host (e.g. `nixos` → `darter`), do it here: the attribute in `flake.nix`
      and the `hosts/<host>/` folder. The first rebuild after a rename needs `.#<newname>`.
- [ ] **One module per desktop**: `modules/desktops/{pantheon,cosmic,gnome,qtile}.nix`,
      imported by the host. Move `services.desktopManager.pantheon.enable` out of
      `hosts/nixos/configuration.nix`.
  - Window managers like Qtile need `services.gnome.gnome-keyring.enable = true;`
    (Mailspring and Mattermost store credentials in the keyring).
  - If two desktops conflict (e.g. GNOME + Pantheon, GNOME + KDE), use `specialisation`s
    for separate boot entries instead of enabling both.
  - Check the cursor theme on each desktop. KDE Plasma ignores it and needs its own setting;
    Hyprland/Sway need `home.pointerCursor.hyprcursor` / `.sway`.

## Home Manager

- [ ] **Default apps** (`xdg.mimeApps.defaultApplications`): rewrite rather than copy
      `~/.config/mimeapps.list`. The Firefox entries point at the Pop-specific
      `userapp-Firefox-Z7SLV3.desktop` (use `firefox.desktop`); mailto → `Mailspring.desktop`.
- [ ] **Autostart** (`xdg.autostart`): Mailspring (`mailspring --background`),
      Mattermost, Remmina applet.
- [ ] *(Optional)* **Shared Everforest palette**: define the colors once and use them in
      `kitty.nix`, `oh-my-posh.nix` (currently named terminal colors), and future desktop themes.
- [ ] *(Optional)* **Dev shell template**: a `flake.nix` with `devShells.default` + `.envrc`
      (`use flake`) for projects, replacing mise (node, python + uv, hugo).

## On the real install (System76 Darter Pro)

- [ ] **Immich**: finish or verify the Google Photos migration, or back up the upload
      folder + Postgres data before wiping the root drive. Don't format the 3.6 TB data drive.
      Decide whether to keep running it (native `services.immich` would replace Docker).
- [ ] **Partition** with a 64 GB swap partition for hibernation.
- [ ] **Regenerate `hardware-configuration.nix`** on the machine, with the data drive mounted
      so it gets a `fileSystems` entry (or declare it by UUID).
- [ ] **User password**: `nixos-install` only sets root's. Run `passwd wingej0` via
      `nixos-enter` before rebooting, or set `initialHashedPassword`.
- [ ] **Clone the repo to `~/.dotfiles`** (`programs.nh.flake` points there).
- [ ] **Hibernation**: set `boot.resumeDevice` to the swap partition's UUID (or `/dev/mapper/...`
      if LUKS); optionally `suspend-then-hibernate` on lid close. Test with `systemctl hibernate`.
- [ ] **DisplayLink**: add `services.xserver.videoDrivers = [ "displaylink" "modesetting" ];`,
      run the `nix-prefetch-url` command printed in the build error, rebuild. If `evdi` fails
      on the zen kernel, try `linuxPackages_latest`.
- [ ] **NordVPN**: integrate your solution.
- [ ] **Backups**: set up a backup job (e.g. `services.restic.backups`).
- [ ] **After first login**: `gh auth login`; copy `~/.histfile` from the old system to keep
      shell history.
