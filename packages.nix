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
    ffmpeg
    imagemagick

    # Software development
    asciinema
    awscli2
    curl
    flyctl
    httpie
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
