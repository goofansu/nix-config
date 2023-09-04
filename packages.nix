{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Common utils
    coreutils
    inetutils
    gnugrep
    gnused
    gawk
    curl
    wget

    # Tools
    asciinema
    ffmpeg
    hugo
    hut
    imagemagick
    unar
    zbar

    # Development
    awscli2
    flyctl
    livebook
    ngrok

    # Languages
    elixir
    elixir-ls
    ruby_3_2
  ];
}
