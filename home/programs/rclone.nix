{ config, lib, pkgs, ... }:
let
  # Remotes created with `rclone config`, each mounted at ~/GoogleDrive/<name>.
  # rclone.conf is left unmanaged: it holds the OAuth tokens rclone refreshes.
  remotes = [
    "sjsd"
    "3dgradebook"
    "personal"
  ];

  mountPoint = name: "${config.home.homeDirectory}/GoogleDrive/${name}";

  mountService = name: {
    name = "rclone-${name}";
    value = {
      Unit = {
        Description = "Google Drive (${name}) on demand via rclone";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        Type = "notify";
        # fusermount3 is a setuid wrapper outside the user service PATH
        Environment = "PATH=/run/wrappers/bin";
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg (mountPoint name)}";
        ExecStart = lib.concatStringsSep " " [
          "${pkgs.rclone}/bin/rclone mount ${name}: ${lib.escapeShellArg (mountPoint name)}"
          "--vfs-cache-mode full" # apps can seek and write; opened files are cached
          "--vfs-cache-max-size 10G"
          "--vfs-cache-max-age 24h"
        ];
        ExecStop = "/run/wrappers/bin/fusermount3 -uz ${lib.escapeShellArg (mountPoint name)}";
        Restart = "on-failure";
        RestartSec = 30;
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
in
{
  systemd.user.services = lib.listToAttrs (map mountService remotes);
}
