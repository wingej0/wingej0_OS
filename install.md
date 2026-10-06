# Installing wingej0_OS

The graphical installer can't install from a flake, so installation is two stages:
install a basic NixOS with the GUI, then switch it to this flake.

## 1. Graphical installer

- **Boot in UEFI mode.** The flake uses systemd-boot. If the machine (or VM) boots in
  legacy BIOS mode, the installer sets up GRUB and the switch to the flake fails at the
  bootloader step. For a VM, use OVMF/EFI firmware.
- **User:** `wingej0`, with a password. The username must match `modules/users.nix`.
- **Hostname:** `nixos`, to match the config name in `flake.nix`.
- **Desktop:** any, or none. The flake replaces it.
- **Swap:** choose **Swap (with Hibernate)**. The installer creates a swap partition about
  the size of RAM. On the Darter Pro, plan for 64 GB; if the installer picks a different
  size, use manual partitioning.
- **Disk encryption:** optional. If enabled, see step 3.
- **Data drive (Darter Pro):** don't format the 3.6 TB data drive.

## 2. Switch to the flake

After rebooting into the new system:

```sh
nix-shell -p git
git clone https://github.com/wingej0/wingej0_OS ~/.dotfiles
cp /etc/nixos/hardware-configuration.nix ~/.dotfiles/hosts/nixos/
```

The copied `hardware-configuration.nix` doesn't need committing to build: it's already
tracked, so the flake uses the modified copy. Commit it on the real machine.

Clone to `~/.dotfiles`, because `programs.nh.flake` points there.

**On the Darter Pro:** mount the data drive before running `nixos-generate-config`
(or before copying, if the installer already generated the file) so it gets a
`fileSystems` entry, or declare it by UUID.

## 3. If the disk is encrypted

Before switching, check `/etc/nixos/configuration.nix`. The installer puts the LUKS
settings there, not in `hardware-configuration.nix`:

```nix
boot.initrd.luks.devices."luks-<uuid>".device = "/dev/disk/by-uuid/<uuid>";
```

With hibernation, there are **two** entries: one for root and one for swap. Copy **both**
into `hosts/nixos/configuration.nix`. Without them, the system can't unlock the disk at
boot, and can't resume from hibernation.

## 4. Hibernation

Set the resume device in `hosts/nixos/configuration.nix`:

```nix
boot.resumeDevice = "/dev/disk/by-uuid/<swap-partition-uuid>";  # unencrypted
# or
boot.resumeDevice = "/dev/mapper/luks-<uuid>";                    # encrypted
```

Get the UUID from `hardware-configuration.nix` or `lsblk -f`. Setting this explicitly
ensures it resumes from the disk partition and never from zram, which lives in RAM and
can't hold a hibernation image.

## 5. Rebuild

```sh
export NIX_CONFIG="experimental-features = nix-command flakes"
sudo nixos-rebuild switch --flake ~/.dotfiles#nixos
```

Reboot. From then on, use `nh os switch`. (`NH_FLAKE` loads at login, so it only works
without arguments after the reboot.)

## 6. After first login

```sh
gh auth login
```

Copy `~/.histfile` from the old system to keep shell history.

### Checks

- [ ] `systemctl status home-manager-wingej0` finished without errors
- [ ] New terminal: oh-my-posh prompt with the NixOS logo, fastfetch output,
      autosuggestions, `ll`, `z`, Ctrl-R
- [ ] kitty: Everforest colors, opacity, FiraCode font
- [ ] `echo $NH_FLAKE` → `/home/wingej0/.dotfiles`, and `nh os switch` works without `.`
- [ ] `systemctl --user show-environment | grep XCURSOR` shows both variables;
      the cursor is Bibata
- [ ] `git push` from `~/.dotfiles` works through the gh credential helper
- [ ] `direnv version` runs
- [ ] `systemctl hibernate` powers off, and starting again returns to the open session.
      A fresh login means resume failed: check `boot.resumeDevice` and the LUKS entries.

## Alternative: command-line install

Partition and mount at `/mnt` as usual, then:

```sh
sudo nixos-generate-config --root /mnt
nix-shell -p git
sudo git clone https://github.com/wingej0/wingej0_OS /mnt/home/wingej0/.dotfiles
sudo cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/wingej0/.dotfiles/hosts/nixos/
export NIX_CONFIG="experimental-features = nix-command flakes"
sudo nixos-install --flake /mnt/home/wingej0/.dotfiles#nixos
sudo nixos-enter --root /mnt -c 'passwd wingej0'
sudo nixos-enter --root /mnt -c 'chown -R wingej0:users /home/wingej0/.dotfiles'
```

`nixos-install` only sets root's password, so set the user's before rebooting. The
`chown` is needed because the clone was made as root. Steps 3, 4 and 6 apply here too
(with encryption, the LUKS entries must be in the flake before running `nixos-install`).
