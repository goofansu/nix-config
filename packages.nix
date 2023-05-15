{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Nix
    nix-prefetch-github
    nixfmt

    # GNU softwares
    coreutils-prefixed
    findutils
    gawk
    gnugrep
    gnupg
    gnused
    inetutils
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
    doggo
    exercism
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
    awscli2
    chromedriver
    elixir
    elixir-ls
    erlang
    flyctl
    httpie
    ngrok
  ];
}
