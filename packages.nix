{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Nix
    nix-prefetch-github
    nixfmt

    # GNU softwares
    coreutils
    findutils
    inetutils
    gawk
    gnugrep
    gnupg
    gnused
    wget

    # Doom Emacs
    deno # format JSON
    fd # better GNU find
    fontconfig # detect fonts
    ripgrep # search tool
    shellcheck # shell script linting
    zstd # undo list compression

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
    imagemagick
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
