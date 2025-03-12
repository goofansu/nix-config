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

    # Interpreters
    ruby
    elixir
    nodejs

    # Language Servers
    next-ls
    nixd

    # Tools
    devenv
    duckdb
    uv

    # Services
    awscli2
    flyctl
    cloudflared
  ];
}
