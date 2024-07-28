{ pkgs, pkgs-unstable, ... }:

let
  stable-packages = with pkgs; [
    # GNU utilities
    coreutils
    findutils
    inetutils
    gnugrep
    gnused
    gawk

    # Common utilities
    curl
    tree
    unar
    wget

    # Tools
    imagemagick
    ffmpeg
  ];

  unstable-packages = with pkgs-unstable; [
    # Development
    hut
    flyctl
    ollama
    duckdb

    # Languages
    elixir
    next-ls
    ruby
    ruby-lsp
    nixd
  ];
in { home.packages = stable-packages ++ unstable-packages; }
