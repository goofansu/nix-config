{ config, pkgs, lib, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs29-macport;
    extraPackages = epkgs: [ epkgs.mu4e ];
  };

  home.packages = with pkgs; [
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
    nixpkgs-fmt

    # :lang org
    graphviz

    # :lang sh
    shfmt
    shellcheck

    # :lang web
    nodePackages.stylelint
    nodePackages.js-beautify

    # :email mu4e
    mu

    # :tools docker
    dockfmt
  ];

  home.activation = {
    installEmacsConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d $HOME/.config/emacs ]; then
        if [ -v DRY_RUN ]; then
          echo "Running installEmacsConfig"
        else
          ${pkgs.git}/bin/git clone https://git.sr.ht/~goofansu/emacs-config ${config.xdg.configHome}/emacs && cd ${config.xdg.configHome}/emacs
          ${pkgs.git}/bin/git remote set-url origin git@git.sr.ht:~goofansu/emacs-config
        fi
      fi
    '';
  };
}
