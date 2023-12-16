{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Common utils
    coreutils
    findutils
    inetutils
    gnugrep
    ripgrep
    gnused
    gawk
    curl
    wget
    tree
    unar
    hut
    fd

    # Tools
    imagemagick
    ffmpeg
    zbar

    # Development
    awscli2
    flyctl
    livebook

    # Languages
    elixir_1_15
    ruby_3_2
    rubyPackages_3_2.ruby-lsp
  ];
}
