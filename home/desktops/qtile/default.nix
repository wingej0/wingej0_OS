{ config, ... }:
{
  # Link ~/.config/qtile straight to the repo, so edits take effect on
  # Super+Shift+r without a rebuild. To pin the config in the store instead,
  # use: xdg.configFile."qtile".source = ./config;
  xdg.configFile."qtile".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/home/desktops/qtile/config";
}
