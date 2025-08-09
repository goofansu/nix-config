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

    # Language Servers
    next-ls
    nixd

    # Package management
    uv

    # Tools
    devenv
    duckdb
    httpie

    # Services
    awscli2
    flyctl
    cloudflared

    # Nix tools
    nix-prefetch-github
    prefetch-npm-deps
    nixpkgs-review
  ];
}
