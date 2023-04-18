{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    shellInit = ''
      set -U hydro_multiline true;
    '';
    interactiveShellInit = ''
      if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
          fenv source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      end

      if test -d $HOME/.asdf
          source ${pkgs.asdf-vm}/share/asdf-vm/asdf.fish
      end
    '';
    plugins = [
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "hydro";
        src = pkgs.fishPlugins.hydro.src;
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
      gist = {
        description = "Work with GitHub gists.";
        body = "if command -sq gh; gh gist $argv; end";
      };
      rm = {
        description = "Ask before removing a file.";
        body = "command rm -i $argv";
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
      e = {
        description = "Edit file in Emacs.";
        body = "emacsclient -s term -a '' -nw $argv";
      };
      ediff = {
        description = "Diff files in Emacs.";
        body = ''
          emacsclient -s term -nw -u -e "(ediff \"$argv[1]\" \"$argv[2]\")"
        '';
      };
      egit = {
        description = "Git in Emacs.";
        body = ''
          emacsclient -s term -nw -u -e '(magit-status)'
        '';
      };
      eman = {
        description = "Man page in Emacs.";
        body = ''
          emacsclient -s term -nw -u -e "(man \"$argv[1]\")"
        '';
      };
      ekill = {
        description = "Kill Emacs.";
        body = "emacsclient -s term -e '(kill-emacs)'";
      };

      # Fuzzy find everything!
      fssh = {
        description = "Fuzzy find and ssh into a host.";
        body = ''
          rg --ignore-case '^host [^*]' ~/.ssh/* | cut -d ' ' -f 2 | fzf | read -l result; and ssh "$result"
        '';
      };
      gcb = {
        description = "Fuzzy find and checkout a git branch.";
        body = ''
          git br | fzf | awk '{print $1}' | read -l result; and git co $result
        '';
      };
      gco = {
        description = "Fuzzy find and checkout a GitHub pull request.";
        body = ''
          gh pr list | fzf | awk '{print $1}' | read -l result; and gh co $result
        '';
      };

      # Rails dev
      load-puma = {
        body = "launchctl load -w ~/Library/LaunchAgents/io.puma.dev.plist";
      };
      unload-puma = {
        body = "launchctl unload ~/Library/LaunchAgents/io.puma.dev.plist";
      };
      reload-puma = {
        body = ''
          if pgrep puma
            unload-puma
          end
          load-puma
        '';
      };

      # Elixir dev
      hex-package = {
        description = "Fetch Elixir package config.";
        body = "mix hex.info $argv | grep 'Config:' | sed 's/Config: //g'";
      };
    };
  };
}
