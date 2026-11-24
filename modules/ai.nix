{ config, pkgs, ... }:
{
  # AI
  environment.systemPackages = with pkgs; [
    antigravity-cli
    antigravity-hub
    claude-code
    (callPackage ../pkgs/claude-desktop.nix { })
  ];

  # Claude Desktop Cowork runs tasks in a QEMU/KVM VM, but only looks for
  # its tools at fixed Debian paths (no $PATH lookup), and the app's asar
  # integrity fuse rules out patching them. OVMF_VARS.fd must sit beside
  # OVMF_CODE.fd: the app derives it by swapping CODE for VARS.
  systemd.tmpfiles.rules = [
    "L+ /usr/bin/qemu-system-x86_64 - - - - ${config.virtualisation.libvirtd.qemu.package}/bin/qemu-system-x86_64"
    "L+ /usr/bin/virtiofsd - - - - ${pkgs.virtiofsd}/bin/virtiofsd"
    "d /usr/share/OVMF 0755 root root -"
    "L+ /usr/share/OVMF/OVMF_CODE.fd - - - - ${pkgs.OVMF.fd}/FV/OVMF_CODE.fd"
    "L+ /usr/share/OVMF/OVMF_VARS.fd - - - - ${pkgs.OVMF.fd}/FV/OVMF_VARS.fd"
  ];

  # Cowork talks to the VM over vsock
  boot.kernelModules = [ "vhost_vsock" ];
}
