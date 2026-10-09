{ lib, ... }:
let
  # Keys for workspaces 1-12
  workspaceKeys = [
    "1"
    "2"
    "3"
    "4"
    "5"
    "6"
    "7"
    "8"
    "9"
    "0"
    "minus"
    "equal"
  ];

  # Builds { "<prefix>-1" = value 1 "1"; ... } for every workspace
  forWorkspaces =
    prefix: value:
    lib.listToAttrs (
      lib.imap1 (i: key: lib.nameValuePair "${prefix}-${toString i}" (value key)) workspaceKeys
    );

  customKeybindings = [
    {
      name = "Terminal";
      command = "kitty";
      binding = "<Super>Return";
    }
    {
      name = "Files";
      command = "nautilus";
      binding = "<Shift><Super>Return";
    }
  ];

  customPath =
    i: "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${toString i}/";
in
{
  dconf.settings = {
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
    }
    // forWorkspaces "switch-to-workspace" (key: [ "<Super>${key}" ])
    // forWorkspaces "move-to-workspace" (key: [ "<Shift><Super>${key}" ]);

    # Super+number opens favorite apps by default, which conflicts with the
    # workspace bindings above
    "org/gnome/shell/keybindings" = forWorkspaces "switch-to-application" (_: [ ]);

    "org/gnome/mutter/wayland/keybindings" = {
      restore-shortcuts = [ ];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      screensaver = [ "<Super>Escape" ];
      custom-keybindings = lib.genList customPath (lib.length customKeybindings);
    };
  }
  // lib.listToAttrs (
    lib.imap0 (
      i: binding: lib.nameValuePair (lib.removeSuffix "/" (lib.removePrefix "/" (customPath i))) binding
    ) customKeybindings
  );
}
