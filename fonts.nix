{ pkgs, ... }:

{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    fontconfig

    # Fonts
    jetbrains-mono
    overpass

    # Patched fonts
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
}
