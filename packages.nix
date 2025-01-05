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

    # Interpreters
    ruby
    elixir

    # Language Servers
    ruby-lsp
    next-ls
    nixd

    # Tools
    devenv
    duckdb
    uv

    # Services
    awscli2
    flyctl
    hut
  ];
}
