{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    zed-editor-fhs
    vscode-fhs
    insomnia
    dbeaver-bin
  ];
}
