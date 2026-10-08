{
  pkgs,
  inputs,
  ...
}:
let
  flexoki-kde-colors = pkgs.runCommand "flexoki-kde-colors" { } ''
    mkdir -p $out/share/color-schemes
    cp ${inputs.flexoki}/kde/*.colors $out/share/color-schemes/
  '';
in
{
  home.packages = [ flexoki-kde-colors ];
}
