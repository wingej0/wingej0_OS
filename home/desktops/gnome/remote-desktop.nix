{ pkgs, username, ... }:
{
  # Start the user service gnome-remote-desktop ships, the same way
  # `systemctl --user enable` would
  xdg.configFile."systemd/user/gnome-session.target.wants/gnome-remote-desktop.service".source =
    "${pkgs.gnome-remote-desktop}/lib/systemd/user/gnome-remote-desktop.service";

  # The username/password and the TLS certificate aren't declared here: set them
  # once in Settings > System > Remote Desktop (or with grdctl), which also
  # generates the certificate at these paths.
  dconf.settings."org/gnome/desktop/remote-desktop/rdp" = {
    enable = true;
    view-only = false;
    screen-share-mode = "mirror";
    tls-cert = "/home/${username}/.local/share/gnome-remote-desktop/certificates/rdp-tls.crt";
    tls-key = "/home/${username}/.local/share/gnome-remote-desktop/certificates/rdp-tls.key";
  };
}
