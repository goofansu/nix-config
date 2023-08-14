{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # System utilities
    coreutils
    findutils
    inetutils
    tree

    # Text processing
    gawk
    gnused

    # Text searching
    gnugrep

    # Network
    curl
    wget

    # Converters
    ffmpeg
    imagemagick

    # Software development
    httpie
    mkcert
    newman
    postman
    tokei

    # Web services
    asciinema
    awscli2
    flyctl
    ngrok

    # Languages
    elixir
    elixir-ls
    ruby
    solargraph
  ];
}
