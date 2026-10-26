{ config, pkgs, ... }:
{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # TEMPORARY: nixpkgs 6bd75267 makes aggregateModules cat a .ko.cer for every
  # external module, but system76, system76-io and evdi install their .ko by
  # hand and ship none, so the modules build fails. Skip missing certs until
  # the packages are fixed (NixOS/nixpkgs#575192; system76: #575724).
  # The assert fails loudly once upstream changes the line, so this can't go stale silently.
  nixpkgs.overlays = [
    (final: prev: {
      aggregateModules =
        modules:
        (prev.aggregateModules modules).override {
          buildEnv =
            args:
            let
              from = "| xargs -d'\\n' cat >> modules.cer";
              to = ''| while read -r f; do if [ -e "$f" ]; then cat "$f"; fi; done >> modules.cer'';
            in
            assert prev.lib.hasInfix from args.postBuild;
            prev.buildEnv (args // { postBuild = builtins.replaceStrings [ from ] [ to ] args.postBuild; });
        };
    })
  ];

  # Set default sleep state to deep sleep
  boot.kernelParams = [ "mem_sleep_default=deep" ];

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

  # Keep the last 10 versions in the boot menu
  boot.loader.systemd-boot.configurationLimit = 10;

  programs.nh = {
    enable = true;
    flake = "/home/wingej0/.dotfiles";
    clean = {
      enable = true;
      extraArgs = "--keep-since 14d --keep 10";
    };
  };

  nix.settings.auto-optimise-store = true;

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
  # GUI print manager (add/configure printers, manage queues) for every desktop
  programs.system-config-printer.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

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
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
