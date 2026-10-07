{ lib, username, ... }:

let
  # Folders on the data drive that get bind-mounted into $HOME
  dataDirs = [
    "Desktop"
    "Documents"
    "Music"
    "Pictures"
    "Videos"
    "Projects"
  ];

  bindMount = dir: {
    name = "/home/${username}/${dir}";
    value = {
      device = "/mnt/data/${dir}";
      fsType = "none";
      options = [
        "bind"
        "x-gvfs-hide"
        "nofail"
      ];
      depends = [ "/mnt/data" ];
    };
  };
in
{
  fileSystems = {
    # 4TB data drive
    "/mnt/data" = {
      device = "/dev/disk/by-uuid/931b5a8b-a364-483a-b9eb-f11e44ec5612";
      fsType = "ext4";
      options = [
        "defaults"
        "nofail"
      ];
    };
  }
  // lib.listToAttrs (map bindMount dataDirs);
}
