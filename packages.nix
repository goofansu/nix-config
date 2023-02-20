{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ansible
    asciinema
    asdf-vm
    coreutils
    deno
    exercism
    fd
    ffmpeg_5
    flyctl
    gist
    gnugrep
    gnused
    htop
    imagemagick
    inetutils
    jq
    lnav
    nix-prefetch-github
    pandoc
    ripgrep
    shellcheck
    tealdeer
    tokei
    tree
    wget
    zstd
  ];
}
