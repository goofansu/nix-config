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
    imagemagick
    ffmpeg
    zbar
    mpv
    youtube-dl

    # Development
    awscli2
    flyctl
    httpie

    # Languages
    elixir_1_16
    ruby_3_2
    rubyPackages_3_2.ruby-lsp
  ];
}
