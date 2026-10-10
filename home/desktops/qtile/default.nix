{ config, pkgs, ... }:
{
  imports = [
    ./scripts.nix
    ./theme.nix
  ];

  # Link ~/.config/qtile straight to the repo, so edits take effect on
  # Super+Shift+r without a rebuild. To pin the config in the store instead,
  # use: xdg.configFile."qtile".source = ./config;
  xdg.configFile."qtile".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/home/desktops/qtile/config";

  # Qtile doesn't start graphical-session.target itself. The startup_once hook
  # starts this target, which pulls it in, and the shutdown hook stops it, so
  # the services below run only while Qtile does.
  systemd.user.targets.qtile-session.Unit = {
    Description = "Qtile session";
    Documentation = [ "man:systemd.special(7)" ];
    BindsTo = [ "graphical-session.target" ];
    Wants = [ "graphical-session-pre.target" ];
    After = [ "graphical-session-pre.target" ];
  };

  # Display profiles. Monitors are matched by make/model/serial because the
  # DisplayLink connector numbers (DP-5, DP-6, ...) can change between boots.
  # `wlr-randr` lists them; `kanshictl reload` applies edits after a switch.
  services.kanshi = {
    enable = true;
    settings = [
      {
        # At the desk: the two MSIs side by side, the ASM centered below,
        # laptop screen off
        profile.name = "docked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "Microstep MSI G27C6 0x000002A0";
            mode = "1920x1080@60Hz";
            position = "0,0";
          }
          {
            criteria = "Microstep MSI G27C6 0x00000038";
            mode = "1920x1080@60Hz";
            position = "1920,0";
          }
          {
            criteria = "ASEM S.p.A. ASM-156UC *";
            mode = "1920x1080@60Hz";
            position = "960,1080";
          }
        ];
      }
      {
        # Home DisplayLink dock: the two Acers side by side, laptop screen off
        profile.name = "home";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "Acer Technologies KB220Q H2 260600CDD5B00";
            mode = "1920x1080@60Hz";
            position = "0,0";
          }
          {
            criteria = "Acer Technologies KB220Q H2 260600CE95B00";
            mode = "1920x1080@60Hz";
            position = "1920,0";
          }
        ];
      }
      {
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            mode = "1920x1080@60Hz";
            position = "0,0";
          }
        ];
      }
    ];
  };

  # Polkit authentication agent
  services.polkit-gnome.enable = true;

  # Clipboard history for text and images
  services.cliphist = {
    enable = true;
    allowImages = true;
  };

  # Notifications; styled in theme.nix
  services.dunst.enable = true;

  # Lock before suspend or hibernate, and on `loginctl lock-session`.
  # -w makes swayidle wait for swaylock to lock before letting the system sleep.
  services.swayidle = {
    enable = true;
    events = {
      before-sleep = "${config.programs.swaylock.package}/bin/swaylock -f";
      lock = "${config.programs.swaylock.package}/bin/swaylock -f";
    };
  };
}
