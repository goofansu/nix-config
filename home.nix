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
    pkgs.tmux
    pkgs.tokei
    pkgs.trash-cli
    pkgs.wget
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
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

  programs.zoxide = {
    enable = true;
  };

  home.file.".asdfrc".source = ./asdfrc;
  home.file.".searchlink".source = ./searchlink;
  home.file.".xrayconfig".source = ./xrayconfig;
}
