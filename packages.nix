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
  ];

  unstable-packages = with pkgs-unstable; [
    # Tools
    imagemagick
    ffmpeg
    duckdb

    # Development
    hut
    flyctl
    ollama

    # Languages
    elixir
    ruby
    ruby-lsp
  ];
in { home.packages = stable-packages ++ unstable-packages; }
