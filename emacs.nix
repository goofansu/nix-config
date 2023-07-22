{ pkgs, lib, ... }:

{
  home.activation = {
    installEmacsConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d $HOME/.config/emacs ]; then
        if [ -v DRY_RUN ]; then
          echo "Running installEmacsConfig"
        else
          ${pkgs.git}/bin/git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
          ${pkgs.git}/bin/git clone https://github.com/goofansu/.doom.d $HOME/.config/doom
        fi
      fi
    '';
  };
}
