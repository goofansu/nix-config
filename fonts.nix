{ pkgs, ... }:

{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    fontconfig

    # Fonts
    alegreya
    iosevka
    iosevka-comfy.comfy
    iosevka-comfy.comfy-motion-duo
    jetbrains-mono
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];
}
