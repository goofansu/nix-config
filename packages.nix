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
    tree
    unar

    # Tools
    imagemagick
    ffmpeg
    hut
    zbar
    paperkey
    qrencode
    csvq

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
