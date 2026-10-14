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
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libGL,
  libgbm,
  libnotify,
  libxkbcommon,
  nspr,
  nss,
  pango,
  systemd,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxshmfence,
}:

# Upstream ships only a .deb with a bundled Electron 31, which nixpkgs no
# longer carries, so the bundled runtime is patched rather than replaced.
stdenv.mkDerivation rec {
  pname = "bibisco";
  version = "5.1.3";

  src = fetchurl {
    url = "https://storage.googleapis.com/bibisco-releases/${version}/bibisco-linux-amd64-${version}.deb";
    sha256 = "1qybn84kq5ls8wv16h53ngx6ddvns1v1hxwfsvm5y4ns5mbyxkih";
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
    libdrm
    libgbm
    libxkbcommon
    nspr
    nss
    pango
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
    libnotify
  ];

  dontWrapGApps = true;

  # The setuid bit on chrome-sandbox cannot be set in the build sandbox
  unpackPhase = ''
    dpkg-deb --fsys-tarfile $src | tar -x --no-same-owner --no-same-permissions
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share
    cp -r usr/lib/bibisco $out/lib
    cp -r usr/share/applications usr/share/pixmaps $out/share/

    # The macOS addon is dead weight on Linux, and a chrome-sandbox without
    # setuid is useless: Electron falls back to the user namespace sandbox
    rm -rf $out/lib/resources/app/bin/darwin-* $out/lib/chrome-sandbox

    # The first run copies the template db out of the store, read-only mode
    # and all, and the app then cannot save its settings
    substituteInPlace $out/lib/resources/app/src/startup.js \
      --replace-fail \
        "fs.copySync(cleanbibiscodbpath, path.join(contextInfo.userDataPath, filename));" \
        "fs.copySync(cleanbibiscodbpath, path.join(contextInfo.userDataPath, filename)); fs.chmodSync(path.join(contextInfo.userDataPath, filename), 0o644);"

    makeWrapper $out/lib/bibisco $out/bin/bibisco \
      "''${gappsWrapperArgs[@]}" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

    runHook postInstall
  '';

  meta = {
    description = "Novel writing software";
    homepage = "https://bibisco.com";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "bibisco";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
