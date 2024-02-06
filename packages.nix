{ pkgs, pkgs-stable, ... }:

let
  stable-packages = with pkgs-stable; [ hut ];
  unstable-packages = with pkgs; [
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
    racket
  ];
in { home.packages = stable-packages ++ unstable-packages; }
