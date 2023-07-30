{ pkgs, ... }:

{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    fontconfig

    # fonts
    emacs-all-the-icons-fonts
    jetbrains-mono
  ];
}
