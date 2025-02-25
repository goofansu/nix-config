{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs30;
    extraPackages = epkgs: [
      epkgs.jinx
      epkgs.eglot
    ];
  };

  home.packages = with pkgs; [
    graphviz # denote-explore
    mupdf-headless # doc-view
    poppler_utils # doc-view
    nixfmt-rfc-style # nix-mode
    pngpaste # org-download
    racket # racket-mode
    ruff # ruff-format
    zstd # undo-fu-session-compression
  ];

  home.activation = {
    installEmacsConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d $HOME/.config/emacs ]; then
        if [ -v DRY_RUN ]; then
          echo "Running installEmacsConfig"
        else
          ${pkgs.git}/bin/git clone https://github.com/goofansu/emacs-config.git ${config.xdg.configHome}/emacs && cd ${config.xdg.configHome}/emacs
          ${pkgs.git}/bin/git remote set-url origin git@github.com:goofansu/emacs-config.git
        fi
      fi
    '';
  };
}
