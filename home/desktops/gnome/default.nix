{ ... }:
{
  imports = [
    ./interface.nix
    ./keybindings.nix
    ./remote-desktop.nix
    ./shell.nix
  ];

  # The theme, icons, font and cursor are written to dconf by the gtk module in
  # home/system/gtk.nix, so they aren't repeated here.
  dconf.enable = true;
}
