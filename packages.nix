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
    cmake
    tree
    unar
    wget

    # Multimedia utilities
    imagemagick
    ffmpeg
    libwebp
    exiftool
    oxipng

    # Runtimes
    ruby
    elixir
    nodejs
    bun
    go

    # Python
    uv
    ruff

    # Nix
    nixd # language server
    nixfmt # formatter
    nix-prefetch-github
    prefetch-npm-deps
    nixpkgs-review
  ];

  unstable-packages = with pkgs-unstable; [
    devenv
    duckdb
    bws
  ];
in
{
  home.packages = stable-packages ++ unstable-packages;
}
