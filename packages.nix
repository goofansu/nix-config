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

    # Doom Emacs
    deno       # format JSON
    fd         # better GNU find
    fontconfig # detect fonts
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
    inetutils
    jq
    lnav
    tealdeer
    tokei
    tree

    # fonts
    emacs-all-the-icons-fonts
    ibm-plex
    jetbrains-mono
    julia-mono
    overpass

    # dev
    ansible
    awscli2
    asdf-vm
    flyctl
  ];
}
