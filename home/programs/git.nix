{ ... }:
{
    programs.git = {
        enable = true;
        settings = {
            user = {
                name = "Jeff Winget";
                email = "jeff@3dgradebook.com";
            };
        };
    };

    programs.gh = {
        enable = true;

        # Use the Nix-installed gh for GitHub credentials (replaces /usr/bin/gh)
        gitCredentialHelper.enable = true;

        settings = {
            git_protocol = "https";
            aliases = {
                co = "pr checkout";
            };
        };
    };
}
