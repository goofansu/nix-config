{ pkgs, pkgs-unstable, ... }:

let
  stable-packages = with pkgs; [
    # GNU utilities
    coreutils
    findutils
    inetutils
    gnugrep
    gnused
    gawk

    # Common utilities
    curl
    tree
    unar
    wget
  ];

  unstable-packages = with pkgs-unstable; [
    # Tools
    fd
    hut
    ripgrep

    # Languages
    elixir
    ruby_3_2
    rubyPackages_3_2.ruby-lsp
  ];
in { home.packages = stable-packages ++ unstable-packages; }
