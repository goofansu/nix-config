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

    # Multimedia utilities
    imagemagick
    ffmpeg
  ];

  unstable-packages = with pkgs-unstable; [
    # Languages
    elixir
    next-ls
    nixd
    ruby
    ruby-lsp
    pipx

    # Tools
    devenv
    duckdb
    httpie

    # Services
    flyctl
    hut
  ];
in
{
  home.packages = stable-packages ++ unstable-packages;
}
