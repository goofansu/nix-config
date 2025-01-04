{ pkgs, ... }:

{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    fontconfig

    # Fonts
    iosevka-comfy.comfy
    iosevka-comfy.comfy-fixed
    iosevka-comfy.comfy-motion-duo
    (nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
  ];
}
