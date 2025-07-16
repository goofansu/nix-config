{ pkgs-unstable, ... }:

{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs-unstable; [
    fontconfig

    # Fonts
    aporetic
    jetbrains-mono
  ];
}
