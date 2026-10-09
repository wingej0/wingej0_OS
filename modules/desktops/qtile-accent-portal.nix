# A one-setting portal backend: answers org.freedesktop.appearance
# accent-color with the given color, so Electron apps like Mailspring get the
# exact Flexoki cyan. Listed ahead of the gnome portal in qtile.nix; every
# other setting (dark mode included) falls through to gnome.
{ lib, runCommand, makeWrapper, python3, glib, accent }:
let
  hex = lib.removePrefix "#" accent;
  channel = i: (lib.fromHexString (builtins.substring i 2 hex)) / 255.0;
  rgb = "${toString (channel 0)}, ${toString (channel 2)}, ${toString (channel 4)}";

  busName = "org.freedesktop.impl.portal.desktop.accent";
  python = python3.withPackages (ps: [ ps.pygobject3 ]);

  script = builtins.toFile "accent-portal.py" ''
    from gi.repository import Gio, GLib

    NAMESPACE = "org.freedesktop.appearance"
    ACCENT = GLib.Variant("(ddd)", (${rgb}))

    XML = """
    <node>
      <interface name="org.freedesktop.impl.portal.Settings">
        <method name="ReadAll">
          <arg type="as" name="namespaces" direction="in"/>
          <arg type="a{sa{sv}}" name="value" direction="out"/>
        </method>
        <method name="Read">
          <arg type="s" name="namespace" direction="in"/>
          <arg type="s" name="key" direction="in"/>
          <arg type="v" name="value" direction="out"/>
        </method>
        <signal name="SettingChanged">
          <arg type="s" name="namespace"/>
          <arg type="s" name="key"/>
          <arg type="v" name="value"/>
        </signal>
        <property name="version" type="u" access="read"/>
      </interface>
    </node>
    """


    def wanted(patterns):
        # An empty list means all namespaces; a trailing * is a prefix match
        return not patterns or any(
            p == NAMESPACE or (p.endswith("*") and NAMESPACE.startswith(p[:-1]))
            for p in patterns
        )


    def on_call(conn, sender, path, iface, method, params, invocation):
        if method == "ReadAll":
            (patterns,) = params.unpack()
            found = {NAMESPACE: {"accent-color": ACCENT}} if wanted(patterns) else {}
            invocation.return_value(GLib.Variant("(a{sa{sv}})", (found,)))
        elif params.unpack() == (NAMESPACE, "accent-color"):
            invocation.return_value(GLib.Variant("(v)", (ACCENT,)))
        else:
            invocation.return_dbus_error(
                "org.freedesktop.portal.Error.NotFound", "Requested setting not found"
            )


    def on_property(conn, sender, path, iface, prop):
        return GLib.Variant("u", 1)


    def on_bus(conn, name):
        node = Gio.DBusNodeInfo.new_for_xml(XML)
        conn.register_object(
            "/org/freedesktop/portal/desktop", node.interfaces[0], on_call, on_property
        )


    Gio.bus_own_name(
        Gio.BusType.SESSION, "${busName}", Gio.BusNameOwnerFlags.NONE, on_bus, None, None
    )
    GLib.MainLoop().run()
  '';
in
runCommand "qtile-accent-portal" { nativeBuildInputs = [ makeWrapper ]; } ''
  makeWrapper ${python}/bin/python3 $out/libexec/qtile-accent-portal \
    --add-flags ${script} \
    --prefix GI_TYPELIB_PATH : ${glib.out}/lib/girepository-1.0

  mkdir -p $out/share/xdg-desktop-portal/portals $out/share/dbus-1/services
  cat > $out/share/xdg-desktop-portal/portals/accent.portal <<EOF
  [portal]
  DBusName=${busName}
  Interfaces=org.freedesktop.impl.portal.Settings
  EOF
  cat > $out/share/dbus-1/services/${busName}.service <<EOF
  [D-BUS Service]
  Name=${busName}
  Exec=$out/libexec/qtile-accent-portal
  EOF
''
