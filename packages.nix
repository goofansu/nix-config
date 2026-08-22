{ pkgs, pkgs-unstable, ... }:

let
  stable-packages = with pkgs; [
    # Agent utilities
    fabric-ai

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

    # Nix
    nixd # language server
    nixfmt # formatter
    nix-prefetch-github
    prefetch-npm-deps
    nixpkgs-review

    # Node.js
    nodejs
    pnpm
    bun

    # Python
    python3
    uv
    ruff

    # Shell
    shellcheck
    shfmt

    # Gondolin (required to build custom images)
    zig
    lz4
    e2fsprogs

    # Rust
    rustup
    just
  ];

  unstable-packages = with pkgs-unstable; [
    # Development utilities
    devenv
    kamal
  ];
in
{
  home.packages = stable-packages ++ unstable-packages;
}
