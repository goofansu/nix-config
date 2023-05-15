{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Nix
    nix-prefetch-github
    nixfmt

    # GNU softwares
    coreutils-prefixed
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
    graphviz # generate graphs in org-roam
    ripgrep # search tool
    shellcheck # shell script linting
    shfmt # formt shell script
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
    doggo
    ffmpeg_5
    htop
    imagemagick
    jq
    lnav
    pandoc
    tealdeer
    tokei
    tree
    wakatime

    # dev
    ansible
    asdf-vm
    awscli2
    flyctl
    httpie
  ];
}
