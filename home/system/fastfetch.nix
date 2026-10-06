{ ... }:
let
    # Nix strings have no escape for ESC, so get it from a JSON string
    esc = builtins.fromJSON ''"\u001b"'';
in
{
    programs.fastfetch = {
        enable = true;
        settings = {
            "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
            display = {
                separator = "  ";
            };
            modules = [
                {
                    type = "custom";
                    format = "┌─────────── ${esc}[1mHardware Information${esc}[0m ───────────┐";
                }
                {
                    type = "host";
                    key = "  󰌢";
                }
                {
                    type = "cpu";
                    key = "  󰻠";
                }
                {
                    type = "gpu";
                    key = "  󰍛";
                }
                {
                    type = "disk";
                    key = "  ";
                }
                {
                    type = "memory";
                    key = "  󰑭";
                }
                {
                    type = "display";
                    key = "  󰍹";
                }
                {
                    type = "custom";
                    format = "├─────────── ${esc}[1mSoftware Information${esc}[0m ───────────┤";
                }
                {
                    type = "os";
                    key = "  ";
                }
                {
                    type = "kernel";
                    key = "  ";
                    format = "{1} {2}";
                }
                {
                    type = "de";
                    key = "  ";
                }
                {
                    type = "wm";
                    key = "  ";
                }
                {
                    type = "shell";
                    key = "  ";
                }
                {
                    type = "terminal";
                    key = "  ";
                }
                {
                    type = "terminalfont";
                    key = "  ";
                }
                {
                    type = "packages";
                    key = "  󰏖";
                }
                {
                    type = "uptime";
                    key = "  󰅐";
                }
                {
                    type = "command";
                    key = "  ";
                    text = "birth_install=$(stat -c %W /var); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days";
                }
                {
                    type = "custom";
                    format = "└────────────────────────────────────────────┘";
                }
                {
                    type = "colors";
                    paddingLeft = 2;
                    symbol = "circle";
                }
            ];
        };
    };
}
