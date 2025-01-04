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

    # Development
    devenv
    flyctl

    # Interpreters
    ruby
    elixir

    # Language Servers
    ruby-lsp
    next-ls
    nixd

    # Tools
    pipx
    duckdb
    httpie
  ];
}
