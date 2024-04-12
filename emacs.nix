{ config, pkgs, lib, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
    extraPackages = epkgs: [ epkgs.mu4e ];
  };

  home.packages = with pkgs; [
    ispell # flyspell-mode
    mu # mu4e
    nixfmt-classic # nix-mode's default formatter
    nixpkgs-fmt # nix-mode's alternative formatter
    racket # racket-mode
    zbar # password-store-otp
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
          ${pkgs.git}/bin/git submodule update --init --recursive
        fi
      fi
    '';
  };
}
