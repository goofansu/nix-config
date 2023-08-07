{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    bash # latest bash is required by eshell
    emacs-all-the-icons-fonts # icons
    fd # better GNU find
    graphviz # org-roam graphs
    ispell # required by flyspell
    nixfmt # Nix code formatting
    nodejs # lsp and copilot.el
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
          ${pkgs.git}/bin/git clone https://github.com/goofansu/.doom.d $HOME/.config/doom
        fi
      fi
    '';
  };
}
