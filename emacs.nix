{ pkgs, lib, ... }:

{
  home.activation = {
    installEmacsConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d $HOME/.emacs.d ]; then
        if [ -v DRY_RUN ]; then
          echo "Running installEmacsConfig"
        else
          ${pkgs.git}/bin/git clone https://github.com/goofansu/rune $HOME/.emacs.d
        fi
      fi
    '';
  };
}
