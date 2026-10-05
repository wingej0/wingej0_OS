{ config, pkgs, ... }:
{
    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Kernel
    boot.kernelPackages = pkgs.linuxPackages_zen;

    # Enable networking
    networking.networkmanager.enable = true;

    # Enable bluetooth
    hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
    };

    # Compressed swap in RAM
    zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 25;
    };

    # Set your time zone.
    time.timeZone = "America/Denver";    

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
    };

    # Configure keymap in X11
    services.xserver.xkb = {
        layout = "us";
        variant = "";
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        # jack.enable = true;
    };

    # Enable flakes
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    
    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;
}