{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # GNU softwares
    coreutils
    inetutils
    gnugrep
    gnused
    gawk

    # Tools
    asciinema
    awscli2
    curl
    ffmpeg
    flyctl
    httpie
    hugo
    imagemagick
    newman
    ngrok
    postman
    tokei

    # Languages
    elixir
    elixir-ls
    ruby
    solargraph
  ];
}
