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

      # GnuPG
      gpg-encrypt = {
        description = "Encrypt a file with GnuPG";
        body = "gpg --encrypt --sign --recipient 3C2DE0F1FB93D0EE $argv[1]";
      };

      # macOS
      reset-launchpad = {
        description = "Reset macOS Launchpad";
        body = ''
          defaults write com.apple.dock ResetLaunchPad -bool true
          killall Dock
        '';
      };

      # Emacs commands
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
      ec = {
        description = "Same as e, but requires the term Emacs server";
        body = "emacsclient -s term -nw -u $argv";
      };
      egit = {
        description = "Version control with magit";
        body = ''
          ec -e "(magit-status)"
        '';
      };
      ediff = {
        description = "Compare two files with ediff";
        body = ''
          ec -e "(ediff \"$argv[1]\" \"$argv[2]\")"
        '';
      };
      eman = {
        description = "Display manual page in Emacs";
        body = ''
          ec -e "(progn (man \"$argv[1]\") (delete-other-windows))"
        '';
      };

      # Fuzzy find everything!
      fssh = {
        description = "Fuzzy find and ssh into a host";
        body = ''
          rg --ignore-case '^host [^*]' ~/.ssh/* | cut -d ' ' -f 2 | fzf | read -l result; and ssh "$result"
        '';
      };
      gcl = {
        description = "Fuzzy find and list commits of the selected git branch";
        body = ''
          git br | fzf | awk '{print $1}' | read -l result; and git log --oneline $result
        '';
      };
      gcb = {
        description = "Fuzzy find and checkout the selected git branch";
        body = ''
          git br | fzf | awk '{print $1}' | read -l result; and git co $result
        '';
      };
      gco = {
        description = "Fuzzy find and checkout the selected pull request";
        body = ''
          gh pr list | fzf | awk '{print $1}' | read -l result; and gh co $result
        '';
      };

      # Elixir dev
      mix-hex-info = {
        description = "Fetch Elixir package config";
        body = "mix hex.info $argv | grep 'Config:' | sed 's/Config: //g'";
      };

      # OpenApply dev
      release-pr-id = {
        description = "Fetch the id of release pull request";
        body = ''
          gh pr list -s open | grep 'release/' | awk '{print $1}'
        '';
      };
    };
  };
}
