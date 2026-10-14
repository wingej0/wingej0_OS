{ config, ... }:
let
  games = "${config.home.homeDirectory}/Games";
in
{
  programs.retroarch = {
    enable = true;

    # Each name maps to pkgs.libretro.<name>
    cores = {
      mgba.enable = true; # GB / GBC / GBA
      snes9x.enable = true; # SNES
      mesen.enable = true; # NES
      genesis-plus-gx.enable = true; # Genesis / Master System / Game Gear
      beetle-psx-hw.enable = true; # PS1
      mupen64plus.enable = true; # N64
    };

    # Applied on every launch; keys left out stay editable in the menu
    settings = {
      video_driver = "vulkan";
      menu_driver = "ozone";
      savefile_directory = "${games}/retroarch/saves";
      savestate_directory = "${games}/retroarch/states";
      rgui_browser_directory = "${games}/roms";
    };
  };
}
