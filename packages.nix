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
    qemu

    # Multimedia utilities
    imagemagick
    ffmpeg
    libwebp
    exiftool
    oxipng
    portaudio

    # Go
    go

    # Node.js
    nodejs_24
    pnpm

    # Python
    python3
    uv
    ruff

    # Nix
    devenv
    nixd # language server
    nixfmt # formatter
    nix-prefetch-github
    prefetch-npm-deps
    nixpkgs-review

    # gondolin (required to build custom images)
    zig
    lz4
    e2fsprogs

    # Data analysis
    duckdb
  ];

  unstable-packages = with pkgs-unstable; [
    bws
    acli
    _1password-cli
  ];
in
{
  home.packages = stable-packages ++ unstable-packages;
}
