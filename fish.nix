{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    shellInit = ''
      set -U hydro_multiline true;
    '';
    plugins = [{
      name = "hydro";
      src = pkgs.fishPlugins.hydro.src;
    }];
    functions = {
      cat = {
        description = "A cat(1) clone with wings";
        body = "if command -sq bat; bat $argv; end";
      };
      rm = {
        description = "Ask before removing a file";
        body = "command rm -i $argv";
      };

      # Emacs
      e = {
        description = "The Emacs version of vi";
        body = "emacsclient -s term -nw -a '' $argv";
      };
      ekill = {
        description = "Kill the term Emacs server";
        body = ''
          emacsclient -s term -e "(kill-emacs)"
        '';
      };

      # Fuzzy find everything!
      fssh = {
        description = "Fuzzy find and ssh into a host";
        body = ''
          rg --ignore-case '^host [^*]' ~/.ssh/* | cut -d ' ' -f 2 | fzf | read -l result; and ${pkgs.kitty}/bin/kitten ssh "$result"
        '';
      };
    };
  };
}
