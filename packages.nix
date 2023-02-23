{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Nix
    nix-prefetch-github

    # GNU softwares
    coreutils
    findutils
    gnugrep
    gnused
    wget

    # Doom Emacs
    deno       # format JSON
    fd         # better GNU find
    fontconfig # detect fonts
    ripgrep    # search tool
    shellcheck # shell script linting
    zstd       # undo list compression

    # fonts
    emacs-all-the-icons-fonts
    ibm-plex
    jetbrains-mono
    julia-mono
    overpass

    # utils
    asciinema
    exercism
    ffmpeg_5
    gist
    imagemagick
    inetutils
    lnav
    tealdeer
    tokei
    tree

    # dev
    ansible
    asdf-vm
    awscli2
    flyctl
  ];
}
