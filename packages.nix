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

    # Emacs
    nodejs # copilot.el
    ispell # spell checking

    # fonts
    emacs-all-the-icons-fonts
    ibm-plex
    jetbrains-mono
    julia-mono
    overpass

    # languages with their language servers
    elixir
    elixir-ls
    ruby
    solargraph

    # utils
    fd
    ffmpeg
    fontconfig
    htop
    httpie
    jq
    mkcert
    pandoc
    ripgrep
    tealdeer
    tokei
    tree

    # services
    asciinema
    awscli2
    flyctl
    ngrok
  ];
}
