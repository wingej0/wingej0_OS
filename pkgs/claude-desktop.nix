{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  bubblewrap,
  cairo,
  cups,
  dbus,
  expat,
  gjs,
  glib,
  gtk3,
  libayatana-appindicator,
  libcap_ng,
  libdrm,
  libGL,
  libgbm,
  libnotify,
  libsecret,
  libseccomp,
  libuuid,
  libxkbcommon,
  nspr,
  nss,
  openssh,
  pango,
  pipewire,
  socat,
  systemd,
  xdg-utils,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxshmfence,
  libxtst,
}:

# Anthropic ships the Linux beta only as a Debian .deb (apt repo) with a
# bundled Electron, so the bundled runtime is patched rather than replaced.
# Newest version: the last "Filename:" line (sort -V) of
# https://downloads.claude.ai/claude-desktop/apt/stable/dists/stable/main/binary-amd64/Packages
stdenv.mkDerivation rec {
  pname = "claude-desktop";
  version = "5.11492.2";

  src = fetchurl {
    url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${version}_amd64.deb";
    hash = "sha256-0QlE+lZjuZdADPZsXHc4/WrPZU+KrqyluZTrFHqms18=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libcap_ng # bundled virtiofsd
    libdrm
    libgbm
    libseccomp # bundled virtiofsd
    libxkbcommon
    nspr
    nss
    pango
    pipewire # claude-native-binding.node
    stdenv.cc.cc.lib # node-pty
    (lib.getLib systemd) # libudev
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxshmfence
  ];

  # dlopen()ed at runtime, so autoPatchelf cannot see them
  runtimeDependencies = [
    (lib.getLib systemd)
    libGL
    libayatana-appindicator
    libnotify
    libsecret
    (lib.getLib libuuid)
    libxtst
  ];

  dontWrapGApps = true;

  # The setuid bit on chrome-sandbox cannot be set in the build sandbox
  unpackPhase = ''
    dpkg-deb --fsys-tarfile $src | tar -x --no-same-owner --no-same-permissions
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share
    cp -r usr/lib/claude-desktop $out/lib
    cp -r usr/share/applications usr/share/icons $out/share/

    # A chrome-sandbox without setuid is useless: Electron falls back to the
    # user namespace sandbox
    rm $out/lib/chrome-sandbox

    # MIME types for .mcpb/.dxt/.skill (the .deb registers these in postinst)
    install -Dm644 $out/lib/resources/linux-mime/com.anthropic.Claude.xml \
      $out/share/mime/packages/com.anthropic.Claude.xml

    # GNOME Shell search provider (also done in postinst)
    sp=$out/lib/resources/gnome-search-provider
    install -Dm644 $sp/com.anthropic.Claude.search-provider.ini \
      $out/share/gnome-shell/search-providers/com.anthropic.Claude.search-provider.ini
    install -Dm644 $sp/com.anthropic.Claude.SearchProvider.service \
      $out/share/dbus-1/services/com.anthropic.Claude.SearchProvider.service
    substituteInPlace $out/share/dbus-1/services/com.anthropic.Claude.SearchProvider.service \
      --replace-fail /usr/bin/gjs ${lib.getExe gjs} \
      --replace-fail /usr/lib/claude-desktop $out/lib

    # Shell wrapper: wrapGAppsHook3 makes makeWrapper a binary wrapper, which
    # would pass the ''${NIXOS_OZONE_WL...} expansion below through literally
    makeShellWrapper $out/lib/claude-desktop $out/bin/claude-desktop \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH : ${
        lib.makeBinPath [
          xdg-utils
          bubblewrap
          socat
          openssh
        ]
      } \
      `# Chromium only uses libsecret on desktops it recognizes (not Qtile), and` \
      `# otherwise falls back to basic_text, where Claude refuses to save the sign-in` \
      --add-flags "--password-store=gnome-libsecret" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

    runHook postInstall
  '';

  meta = {
    description = "Desktop application for Claude.ai (Linux beta)";
    homepage = "https://claude.com/download";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "claude-desktop";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
