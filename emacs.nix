{ config, pkgs, lib, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs29-macport;
    extraPackages = epkgs: [ epkgs.mu4e ];
  };

  home.packages = with pkgs; [ mu nixfmt nixpkgs-fmt ];

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
