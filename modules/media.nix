{
  config,
  pkgs,
  inputs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    obs-studio
    # Qt's GTK3 file dialog (used under GNOME) aborts without GTK3's
    # gsettings schemas, which the upstream wrapper doesn't include
    (symlinkJoin {
      name = "kdenlive";
      paths = [ kdePackages.kdenlive ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/kdenlive \
          --prefix XDG_DATA_DIRS : ${gtk3}/share/gsettings-schemas/${gtk3.name} \
          --prefix XDG_DATA_DIRS : ${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}
      '';
    })
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
