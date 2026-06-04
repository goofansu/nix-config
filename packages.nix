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

    # Python
    python3
    uv
    ruff

    # Nix
    nixd # language server
    nixfmt # formatter
    nix-prefetch-github
    prefetch-npm-deps
    nixpkgs-review

    # gondolin (required to build custom images)
    zig
    lz4
    e2fsprogs
  ];

  unstable-packages = with pkgs-unstable; [
    # Agent utilities
    acli
    ast-grep
    yq

    # Password managers
    bws
    _1password-cli

    # Node.js
    nodejs_24
    pnpm

    # Development
    devenv
    kamal
  ];
in
{
  home.packages = stable-packages ++ unstable-packages;
}
