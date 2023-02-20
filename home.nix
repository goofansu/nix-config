{ pkgs, ... }: {
  home.username = "james";
  home.homeDirectory = "/Users/james";
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;

  home.packages = [
    pkgs.ansible
    pkgs.asciinema
    pkgs.asdf-vm
    pkgs.cmake
    pkgs.coreutils
    pkgs.deno
    pkgs.exercism
    pkgs.fd
    pkgs.ffmpeg_5
    pkgs.flyctl
    pkgs.gist
    pkgs.gnugrep
    pkgs.graphviz
    pkgs.htop
    pkgs.hyperfine
    pkgs.imagemagick
    pkgs.inetutils
    pkgs.jq
    pkgs.lnav
    pkgs.pandoc
    pkgs.ripgrep
    pkgs.shellcheck
    pkgs.tealdeer
    pkgs.tokei
    pkgs.wget
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fish = {
    enable = true;
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
    ];
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
