# DisplayLink driver for the home dock.
#
# The driver is unfree and must be in the Nix store before building. After
# accepting the EULA at https://www.synaptics.com/products/displaylink-graphics/downloads/ubuntu,
# fetch it with:
#
#   nix-prefetch-url --name displaylink-620.zip https://www.synaptics.com/sites/default/files/exe_files/2025-09/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.2-EXE.zip
#
# Repeat this whenever nixpkgs bumps the driver version (the build error
# prints the new command).
{ ... }:
{
  # Loads the evdi kernel module, installs the udev rule that starts the
  # DisplayLink Manager (dlm) service when the dock is plugged in, and hooks
  # dlm into suspend/resume.
  services.xserver.videoDrivers = [
    "displaylink"
    "modesetting"
  ];
}
