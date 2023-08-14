{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # System utilities
    coreutils
    findutils
    inetutils
    htop
    tree

    # Text processing
    gawk
    gnused

    # Text searching
    gnugrep

    # Network
    curl
    wget

    # Security
    gnupg
    pass

    # Converters
    ffmpeg
    imagemagick
    pandoc

    # Software development
    httpie
    jq
    mkcert
    newman
    postman
    tealdeer
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
