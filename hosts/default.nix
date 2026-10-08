{ hostname, ... }:
{
  imports =
    if hostname == "darter-pro" then
      [
        ./darter-pro/configuration.nix
        ./../modules/system.nix
        ./../modules/base.nix
        ./../modules/ai.nix
        ./../modules/browsers.nix
        ./../modules/communication.nix
        ./../modules/development.nix
        ./../modules/fonts.nix
        ./../modules/games.nix
        ./../modules/media.nix
        ./../modules/office.nix
        ./../modules/shells.nix
        ./../modules/system76.nix
        ./../modules/virtualization.nix
        ./../modules/users.nix
        ./../modules/desktops
      ]
    else
      [ ];
}
