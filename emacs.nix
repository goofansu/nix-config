{ pkgs, lib, ... }:

{
  home.activation = {
    installDoomEmacs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d $HOME/.emacs.d ]; then
        if [ -v DRY_RUN ]; then
          echo "Running installDoomEmacs"
        else
          ${pkgs.git}/bin/git clone --depth=1 --single-branch https://github.com/doomemacs/doomemacs $HOME/.emacs.d
          ${pkgs.git}/bin/git clone https://github.com/goofansu/.doom.d $HOME/.doom.d
        fi
      fi
    '';
  };
}
