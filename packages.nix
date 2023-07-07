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
    guile # learn SICP with scheme
    nodejs # copilot.el
    pandoc # markdown compiler
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

    # languages
    elixir
    elixir-ls
    ruby

    # utils
    ffmpeg
    graphviz
    htop
    httpie
    jq
    mkcert
    tealdeer
    tokei
    tree

    # services
    asciinema
    awscli2
    exercism
    flyctl
    ngrok
    wakatime
  ];
}
