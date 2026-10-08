{
  inputs,
  username,
  hostname,
  desktop,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = "Jeff Winget";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit
        inputs
        username
        hostname
        desktop
        ;
    };
    backupFileExtension = "backup";

    users.${username} = {
      imports = [ ../home/home.nix ];
      programs.home-manager.enable = true;
      home = {
        username = "${username}";
        homeDirectory = "/home/${username}";
      };
    };
  };
}
