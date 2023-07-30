{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # GNU softwares
    coreutils
    coreutils-prefixed
    findutils
    inetutils
    gawk
    gnugrep
    gnupg
    gnused
    wget

    # utils
    asciinema
    awscli2
    curl
    ffmpeg
    flyctl
    htop
    httpie
    imagemagick
    jq
    mkcert
    ngrok
    pandoc
    ripgrep
    tealdeer
    tokei
    tree

    # languages
    elixir
    elixir-ls
    ruby
    solargraph
  ];
}
