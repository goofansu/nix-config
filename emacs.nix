{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    bash # latest bash is required by eshell
    coreutils-prefixed # gls is required by dired module
    emacs-all-the-icons-fonts # icons
    fd # better GNU find
    gnutls # required by irc module
    graphviz # org-roam graphs
    ispell # required by flyspell
    nixfmt # Nix code formatting
    shellcheck # shell script linting
    shfmt # shell script code formatting
    zstd # undo list compression
  ];

  home.activation = {
    installEmacsConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d $HOME/.config/emacs ]; then
        if [ -v DRY_RUN ]; then
          echo "Running installEmacsConfig"
        else
          ${pkgs.git}/bin/git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
          ${pkgs.git}/bin/git clone https://codeberg.org/goofansu/.doom.d $HOME/.config/doom
        fi
      fi
    '';
  };
}
