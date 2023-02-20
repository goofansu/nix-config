{ pkgs, ... }: {
  home.username = "james";
  home.homeDirectory = "/Users/james";
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    ansible
    asciinema
    asdf-vm
    cmake
    coreutils
    deno
    exercism
    fd
    ffmpeg_5
    flyctl
    gist
    gnugrep
    graphviz
    htop
    hyperfine
    imagemagick
    inetutils
    jq
    lnav
    nix-prefetch-github
    pandoc
    ripgrep
    shellcheck
    tealdeer
    tokei
    wget
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = "fenv source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh";
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

  programs.gh = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Yejun Su";
    userEmail = "yejun@hey.com";
    aliases = {
      ci = "commit";
      co = "checkout";
    };
    signing = {
      key = null;
      signByDefault = true;
      gpgPath = "/usr/local/bin/gpg";
    };
    extraConfig = {
      init = { defaultBranch = "main"; };
      pull = { rebase = true; };
      github = { user = "goofansu"; };
    };
    ignores = [
      ".DS_Store"
      "*.log*"
      ".elixir_ls"
      "node_modules"
    ];
    includes = [
      { path = "~/.gitconfig_local"; }
    ];
    delta = {
      enable = true;
    };
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
      style = "plain";
    };
  };

  programs.exa = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
  };

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
  };

  home.file.".asdfrc".text = "legacy_version_file = yes";
  home.file.".gemrc".text = "gem: --no-document";
  home.file.".xrayconfig".text = ":editor: '/opt/homebrew/bin/emacsclient -s gui -c $file'";
}
