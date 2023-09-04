{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    emacs29-macport

    # Doom Emacs prerequisites
    findutils
    ripgrep
    fd

    # Doom Emacs dependencies
    # :emacs dired
    coreutils-prefixed

    # :emacs undo
    zstd

    # :lang lsp
    nodejs_20

    # :lang nix
    nixfmt

    # :lang org
    graphviz

    # :lang sh
    shfmt
    shellcheck

    # :lang web
    nodePackages.stylelint
    nodePackages.js-beautify
  ];

  home.activation = {
    installEmacsConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d $HOME/.config/emacs ]; then
        if [ -v DRY_RUN ]; then
          echo "Running installEmacsConfig"
        else
          ${pkgs.git}/bin/git clone --depth 1 https://github.com/doomemacs/doomemacs ${config.xdg.configHome}/emacs
          ${pkgs.git}/bin/git clone https://git.sr.ht/~goofansu/.doom.d ${config.xdg.configHome}/doom
        fi
      fi
    '';
  };
}
