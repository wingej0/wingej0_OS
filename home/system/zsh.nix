{ config, pkgs, ... }:
{
    programs.zsh = {
        enable = true;

        # Completion
        enableCompletion = true;

        # Suggestions and autohighlighting
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        # bindkey -e
        defaultKeymap = "emacs";

        history = {
            path = "${config.home.homeDirectory}/.histfile";
            size = 50000;
            save = 50000;
            ignoreAllDups = true;
            ignoreSpace = true;
            share = true;
        };

        shellAliases = {
            ls = "eza --icons";
            ll = "eza -la --icons";
            lt = "eza --tree --icons";
            cat = "bat";
            du = "dust";
            grep = "rg";
            zed = "zeditor";
        };

        initContent = ''
            fastfetch
        '';
    };
}