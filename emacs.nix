{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.jinx
      epkgs.eglot
    ];
  };

  home.packages = with pkgs; [
    graphviz # denote-explore
    mupdf-headless # doc-view
    poppler_utils # doc-view
    zstd # undo-fu-session-compression
  ];

  home.activation = {
    installEmacsConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d ${config.xdg.configHome}/emacs ]; then
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
