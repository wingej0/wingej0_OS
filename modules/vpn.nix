{ username, ... }:
{
  # NordVPN daemon (nixpkgs module)
  services.nordvpn.enable = true;
  users.users.${username}.extraGroups = [ "nordvpn" ];

  networking.firewall = {
    checkReversePath = false;
    allowedTCPPorts = [ 443 ];
    allowedUDPPorts = [ 1194 ];
  };
}
