{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # GNU softwares
    coreutils
    findutils
    gnugrep
    gnused
    wget

    # Nix
    nix-prefetch-github

    # Doom Emacs prerequisites
    deno       # format JSON
    fd         # better GNU find
    pandoc     # markdown compiler
    ripgrep    # search tool
    shellcheck # shell script linting
    zstd       # undo list compression

    # media processing
    ffmpeg_5
    imagemagick

    # utils
    asciinema
    exercism
    gist
    htop
    inetutils
    jq
    lnav
    tealdeer
    tokei
    tree

    # dev
    ansible
    awscli2
    asdf-vm
    flyctl
  ];
}
