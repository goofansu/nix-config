{ pkgs, ... }:

{
  home.packages = with pkgs; [
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

    # Tools
    devenv
    duckdb
    ast-grep

    # Nix tools
    nixd # language server
    nixfmt-rfc-style # formatter
    nix-prefetch-github
    prefetch-npm-deps
    nixpkgs-review
  ];
}
