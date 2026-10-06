{ ... }:
{
  programs.direnv = {
    enable = true;

    # Caches `use flake` shells so entering a project is instant after the first load,
    # and keeps them from being garbage-collected by nix.gc
    nix-direnv.enable = true;

    # Settings for ~/.config/direnv/direnv.toml
    config = {
      global = {
        # Don't print the long list of exported variables on every cd
        hide_env_diff = true;
      };
    };
  };
}
