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

    # Services
    awscli2
    flyctl
    cloudflared
  ];

  unstable-packages = with pkgs-unstable; [
    # LLM tools
    github-mcp-server
    claude-code
  ];
in
{
  home.packages = stable-packages ++ unstable-packages;
}
