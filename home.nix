{ pkgs, ... }: {
  home.username = "james";
  home.homeDirectory = "/Users/james";
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;

  home.packages = [
    pkgs.ripgrep
  ];

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
    delta = {
      enable = true;
    };
  };

  programs.bat = {
    enable = true;
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
}
