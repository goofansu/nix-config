{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Common utils
    coreutils
    findutils
    inetutils
    gnugrep
    ripgrep
    gnused
    gawk
    curl
    wget
    tree
    unar
    hut
    fd

    # Tools
    ffmpeg
    imagemagick
    youtube-dl
    zbar

    # Development
    httpie

    # Languages
    elixir_1_16
    ruby_3_2
    rubyPackages_3_2.ruby-lsp
  ];
}
