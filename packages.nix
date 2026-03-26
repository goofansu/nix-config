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
    tmux

    # Multimedia utilities
    imagemagick
    ffmpeg
    libwebp
    exiftool
    oxipng
    portaudio

    # Runtimes
    nodejs_24
    go

    # Python
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
