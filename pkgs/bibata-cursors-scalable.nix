# Bibata-Modern-Classic with an added cursors_scalable folder.
#
# GNOME Shell 51 only loads SVG cursors
# (icons/<theme>/cursors_scalable/<name>/metadata.json, see st-cursor.c) and
# uses Adwaita for anything else, so the XCursor-only nixpkgs package is ignored
# there. This builds the SVG cursors from Bibata's own sources and keeps the
# XCursor files for every other desktop and toolkit.
{
  runCommand,
  bibata-cursors,
  python3,
  writeText,
}:
let
  theme = "Bibata-Modern-Classic";

  script = writeText "bibata-scalable.py" ''
    import json, pathlib, sys, tomllib

    src, out = map(pathlib.Path, sys.argv[1:])
    render = json.loads((src / "render.json").read_text())["${theme}"]
    svgs = src / render["dir"]
    config = tomllib.loads((src / "configs/normal/x.build.toml").read_text())["cursors"]
    defaults = config.pop("fallback_settings")

    def recolor(svg):
        for c in render["colors"]:
            for match in (c["match"], c["match"].lower()):
                svg = svg.replace(match, c["replace"])
        return svg

    for cursor in config.values():
        name = cursor["x11_name"]
        stem = cursor["png"].removesuffix(".png")
        if stem.endswith("-*"):
            base = stem[:-2]
            frames = sorted((svgs / base).glob(f"{base}-*.svg"))
        else:
            frames = [svgs / f"{stem}.svg"]
        assert frames, f"no SVG for {name}"

        target = out / name
        target.mkdir(parents=True)
        metadata = []
        for frame in frames:
            (target / frame.name).write_text(recolor(frame.read_text()))
            entry = {
                "filename": frame.name,
                # Hotspots are in the coordinates of the 256px SVG canvas
                "hotspot_x": cursor.get("x_hotspot", defaults["x_hotspot"]),
                "hotspot_y": cursor.get("y_hotspot", defaults["y_hotspot"]),
                "nominal_size": 256,
            }
            if len(frames) > 1:
                entry["delay"] = defaults["x11_delay"]
            metadata.append(entry)
        (target / "metadata.json").write_text(json.dumps(metadata, indent=2))

        for alias in cursor.get("x11_symlinks", []):
            (out / alias).symlink_to(name)

    # Bibata doesn't have this one; GNOME Shell asks for it
    (out / "all-resize").symlink_to("move")
  '';
in
runCommand "bibata-cursors-scalable-${bibata-cursors.version}"
  {
    nativeBuildInputs = [ python3 ];
    meta = {
      inherit (bibata-cursors.meta) homepage license platforms;
      description = "${theme} cursors with SVG versions for GNOME Shell 51+";
    };
  }
  ''
    mkdir -p $out/share/icons
    cp -r ${bibata-cursors}/share/icons/${theme} $out/share/icons/
    chmod -R u+w $out
    python3 ${script} ${bibata-cursors.src} $out/share/icons/${theme}/cursors_scalable
  ''
