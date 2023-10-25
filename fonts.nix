{ pkgs, ... }:

{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    fontconfig

    # Fonts
    iosevka
    jetbrains-mono
    noto-fonts-cjk-sans
  ];
}
