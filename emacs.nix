{ config, pkgs, lib, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
    extraPackages = epkgs: [ epkgs.jinx epkgs.eglot ];
  };

  home.packages = with pkgs; [
    nixfmt-classic # nix-mode's default formatter
    nixpkgs-fmt # nix-mode's alternative formatter
    pngpaste # org-download
    racket # racket-mode
    zstd # undo-fu-session-compression
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
