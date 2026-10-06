{ config, pkgs, ... }:
{
  # AI
  environment.systemPackages = with pkgs; [
    antigravity-cli
    antigravity-hub
    claude-code
  ];
}
