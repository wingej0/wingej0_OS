{ config, pkgs, ... }:
{
    programs.oh-my-posh = {
        enable = true;
        settings = {
            console_title_template = "{{ .Shell }} in {{ .Folder }}";
            version = 3;
            final_space = true;
            blocks = [
                {
                    type = "prompt";
                    alignment = "left";
                    newline = true;
                    segments = [
                        {
                            leading_diamond = "";
                            trailing_diamond = "";
                            template = "  {{ if .SSHSession }} {{ end }}{{ .HostName }} ";
                            foreground = "black";
                            background = "white";
                            type = "session";
                            style = "diamond";
                        }
                        {
                            template = "  {{ path .Path .Location }} ";
                            foreground = "black";
                            leading_diamond = "<transparent,background></>";
                            trailing_diamond = "";
                            background = "cyan";
                            type = "path";
                            style = "diamond";
                            properties = {
                                style = "folder";
                            };
                        }
                        {
                            template = "  {{ .Venv }} ";
                            foreground = "black";
                            leading_diamond = "<transparent,background></>";
                            trailing_diamond = "";
                            background = "red";
                            type = "python";
                            style = "diamond";
                            properties = {
                                display_mode = "environment";
                                fetch_virtual_env = true;
                            };
                        }
                        {
                            template = " {{ if .UpstreamURL }}{{ url .UpstreamIcon .UpstreamURL }} {{ end }}{{ .HEAD }}{{if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }}  {{ .Working.String }}{{ end }}{{ if .Staging.Changed }}  {{ .Staging.String }}{{ end }} ";
                            foreground = "black";
                            leading_diamond = "<transparent,background></>";
                            trailing_diamond = "";
                            background = "yellow";
                            type = "git";
                            style = "diamond";
                            foreground_templates = [
                                "{{ if or (.Working.Changed) (.Staging.Changed) }}black{{ end }}"
                                "{{ if and (gt .Ahead 0) (gt .Behind 0) }}white{{ end }}"
                                "{{ if gt .Ahead 0 }}white{{ end }}"
                            ];
                            background_templates = [
                                "{{ if or (.Working.Changed) (.Staging.Changed) }}yellow{{ end }}"
                                "{{ if and (gt .Ahead 0) (gt .Behind 0) }}red{{ end }}"
                                "{{ if gt .Ahead 0 }}#49416D{{ end }}"
                                "{{ if gt .Behind 0 }}#7A306C{{ end }}"
                            ];
                            properties = {
                                branch_max_length = 25;
                                fetch_status = true;
                                fetch_upstream_icon = true;
                            };
                        }
                        {
                            leading_diamond = "<transparent,background></>";
                            trailing_diamond = "";
                            foreground = "black";
                            background = "blue";
                            template = " {{ if gt .Code 0 }} {{ reason .Code }}{{ else }} {{ end }} ";
                            type = "status";
                            style = "diamond";
                            background_templates = [ "{{ if .Error }}red{{ end }}" ];
                            properties = {
                                always_enabled = true;
                            };
                        }
                    ];
                }
                {
                    type = "rprompt";
                    segments = [
                        {
                            leading_diamond = "";
                            trailing_diamond = "<transparent,background></>";
                            foreground = "black";
                            background = "blue";
                            type = "shell";
                            style = "diamond";
                            background_templates = [ "{{ if .Error }}red{{ end }}" ];
                        }
                        {
                            type = "executiontime";
                            style = "diamond";
                            leading_diamond = "";
                            trailing_diamond = "<transparent,background></>";
                            foreground = "black";
                            background = "cyan";
                            template = " {{ .FormattedMs }} ";
                        }
                        {
                            leading_diamond = "";
                            trailing_diamond = "";
                            template = " at {{ .CurrentDate | date \"15:04:05\" }} ";
                            foreground = "black";
                            background = "white";
                            type = "time";
                            style = "diamond";
                        }
                    ];
                }
            ];
        };
    };
}
