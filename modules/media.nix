{
  config,
  pkgs,
  inputs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    obs-studio
    kdePackages.kdenlive
    mpv
    audacity
    gimp
    annotator
    ffmpeg
    loupe
    kooha
    gnome-podcasts
    cozy

    # Sidra music player installed from flake input
    inputs.sidra.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
