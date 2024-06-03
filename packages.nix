{ pkgs, pkgs-stable, ... }:

let
  stable-packages = with pkgs-stable; [
    # GNU utilities
    coreutils
    findutils
    inetutils
    gnugrep
    gnused
    gawk
  ];

  unstable-packages = with pkgs; [
    # Tools
    curl
    fd
    hut
    ripgrep
    tree
    unar
    wget

    # Languages
    elixir
    ruby_3_2
    rubyPackages_3_2.ruby-lsp
  ];
in { home.packages = stable-packages ++ unstable-packages; }
