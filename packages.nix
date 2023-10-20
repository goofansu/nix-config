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
    hut

    # Tools
    imagemagick
    ffmpeg
    zbar
    qrencode
    paperkey

    # Development
    awscli2
    flyctl
    livebook

    # Languages
    elixir_1_15
    ruby_3_2
  ];
}
