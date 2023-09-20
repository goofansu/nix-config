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
    csvq
    ffmpeg
    hugo
    hut
    imagemagick
    paperkey
    qrencode
    tree
    unar
    zbar

    # Development
    awscli2
    flyctl
    livebook

    # Languages
    elixir
    elixir-ls
    ruby_3_2
  ];
}
