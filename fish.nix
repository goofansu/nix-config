{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
          fenv source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      end

      if test -d $HOME/.asdf
          source $HOME/.nix-profile/share/asdf-vm/asdf.fish
      end
    '';
    shellInit = ''
      # LANG
      set -gx LANG "en_US.UTF-8"
      set -gx LC_ALL "en_US.UTF-8"

      # EDITOR
      set -gx EDITOR "emacsclient -s term -t"
      set -gx VISUAL "emacsclient -s term -t"

      # Emacs server
      set -gx EMACS_SERVER_NAME "gui"

      # Erlang
      set -gx KERL_BUILD_DOCS yes
      set -gx ERL_AFLAGS "-kernel shell_history enabled"

      # PATH
      set -gx PATH $HOME/.emacs.d/bin $PATH
      set -gx PATH ./bin $PATH
    '';
    plugins = [
      { name = "done"; src = pkgs.fishPlugins.done.src; }
      { name = "hydro"; src = pkgs.fishPlugins.hydro.src; }
      {
        name = "dracula";
        src = pkgs.fetchFromGitHub {
          owner = "dracula";
          repo = "fish";
          rev = "0e51af5e5346e5d24efabd43fb4631e2a8fd1b70";
          sha256 = "YXh6pPJ9dJDPpq1kX5xd1edoOaH6jDq8pDOkx3k03/0=";
        };
      }
      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "85f863f20f24faf675827fb00f3a4e15c7838d76";
          sha256 = "+FUBM7CodtZrYKqU542fQD+ZDGrd2438trKM0tIESs0=";
        };
      }
      {
        name = "foreign-env";
        src = pkgs.fetchFromGitHub {
          "owner" = "oh-my-fish";
          "repo" = "plugin-foreign-env";
          "rev" = "3ee95536106c11073d6ff466c1681cde31001383";
          "sha256" = "vyW/X2lLjsieMpP9Wi2bZPjReaZBkqUbkh15zOi8T4Y=";
        };
      }
    ];
    functions = {
      cat = {
        description = "A cat(1) clone with wings.";
        body = "if command -sq bat; bat $argv; end";
      };
      find = {
        description = "A simple, fast and user-friendly alternative to `find`.";
        body = "if command -sq fd; fd $argv; end";
      };
      ls = {
        description = "A modern replacement for ‘ls’.";
        body = "if command -sq exa; exa $argv; end";
      };
      rm = {
        description = "Ask before removing a file.";
        body = "command rm -i $argv";
      };
      vi = {
        description = "Emacs in the terminal.";
        body = "emacsclient -s term -nw $argv";
      };

      # macOS
      reset-launchpad = {
        description = "Reset macOS Launchpad.";
        body = ''
          defaults write com.apple.dock ResetLaunchPad -bool true
          killall Dock
        '';
      };

      # Emacs commands
      emacs-server = {
        description = "Start Emacs in terminal.";
        body = "emacs --daemon=term";
      };
      magit = {
        description = "Manage Git repository in Emacs.";
        body = ''
          emacsclient -s term -nw -u -e "(magit-status)"
        '';
      };
      ediff = {
        description = "Compare files in Emacs.";
        body = ''
          emacsclient -s term -nw -u -e "(ediff \"$argv[1]\" \"$argv[2]\")"
        '';
      };

      # Fuzzy find everything!
      fssh = {
        description = "Fuzzy find and ssh into a host.";
        body = ''
          rg --ignore-case '^host [^*]' ~/.ssh/* | cut -d ' ' -f 2 | fzf | read -l result; and ssh "$result"
        '';
      };
      fco = {
        description = "Fuzzy find and checkout a Git branch.";
        body = ''
          git branch --all | grep -v HEAD | string trim | fzf | read -l result; and git checkout "$result"
        '';
      };

      # Rails dev
      load-puma = {
        body = "launchctl unload ~/Library/LaunchAgents/io.puma.dev.plist";
      };
      unload-puma = {
        body = "launchctl load -w ~/Library/LaunchAgents/io.puma.dev.plist";
      };
      kill-spring = {
        body = "ps -ef | grep spring | grep -v grep | awk '{print $2}' | xargs -I {} kill -9 {}";
      };

      # Elixir dev
      hex-package = {
        description = "Fetch Elixir package config.";
        body = "mix hex.info $argv | grep 'Config:' | sed 's/Config: //g'";
      };
    };
  };
}
