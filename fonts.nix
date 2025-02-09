{ pkgs, pkgs-unstable, ... }:

{
  fonts.fontconfig.enable = true;
  home.packages = [
    pkgs.fontconfig

    # Fonts
    pkgs-unstable.aporetic
    pkgs.jetbrains-mono
  ];
}
