{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Base Packages
    zsh
    zsh-powerlevel10k
    git
    gh
    wget
    vim
    htop
    acpi
    killall
    fzf
    fastfetch
    gparted
    eza
    rclone
    yazi
    btop
    lshw
    seahorse
    gnome-keyring
    file-roller
    ecryptfs
    mailspring
    anytype
    google-chrome
    yt-dlp
    annotator
    ffmpeg
    vscode
    xwayland

    tela-circle-icon-theme
    cosmic-ext-applet-clipboard-manager
  ];

  programs.xwayland.enable = true;

  environment.sessionVariables = {
    COSMIC_DATA_CONTROL_ENABLED = "1"; 
  };

  programs.seahorse.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.wingej0.enableGnomeKeyring = true;
  programs.ssh.askPassword = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
}