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
    lnav

    # Services
    awscli2
    flyctl
    cloudflared
  ];
}
