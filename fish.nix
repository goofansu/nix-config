{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    shellInit = ''
      set -U hydro_multiline true;
    '';
    plugins = [
      {
        name = "done";
        src = pkgs.fetchFromGitHub {
          owner = "franciscolourenco";
          repo = "done";
          rev = "d6abb267bb3fb7e987a9352bc43dcdb67bac9f06";
          sha256 = "6oeyN9ngXWvps1c5QAUjlyPDQwRWAoxBiVTNmZ4sG8E=";
        };
      }
      {
        name = "hydro";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "hydro";
          rev = "41b46a05c84a15fe391b9d43ecb71c7a243b5703";
          sha256 = "zmEa/GJ9jtjzeyJUWVNSz/wYrU2FtqhcHdgxzi6ANHg=";
        };
      }
      {
        name = "dracula";
        src = pkgs.fetchFromGitHub {
          owner = "dracula";
          repo = "fish";
          rev = "0e51af5e5346e5d24efabd43fb4631e2a8fd1b70";
          sha256 = "YXh6pPJ9dJDPpq1kX5xd1edoOaH6jDq8pDOkx3k03/0=";
        };
      }
    ];
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
