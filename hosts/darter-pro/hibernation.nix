# Hibernation to the swap partition, and suspend-then-hibernate on lid close.
{ ... }:
{
  # Same partition as swapDevices in hardware-configuration.nix.
  boot.resumeDevice = "/dev/disk/by-uuid/735b534a-4dc4-4644-84df-8029a91177c7";

  # Closing the lid suspends; after 2 hours asleep the machine wakes briefly,
  # writes RAM to swap and powers off. With external monitors attached
  # (docked), closing the lid still does nothing.
  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  systemd.sleep.settings.Sleep.HibernateDelaySec = "2h";
}
