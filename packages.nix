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
    libwebp
    exiftool

    # Runtimes
    ruby
    elixir
    nodejs

    # Python
    uv
    ruff

    # Nix
    nixd # language server
    nixfmt-rfc-style # formatter
    nix-prefetch-github
    prefetch-npm-deps
    nixpkgs-review
  ];

  unstable-packages = with pkgs-unstable; [
    devenv
    duckdb
    ast-grep
  ];
in
{
  home.packages = stable-packages ++ unstable-packages;
}
