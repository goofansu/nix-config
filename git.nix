{
  programs.gh = {
    enable = true;
    settings = {
      aliases = {
        co = "pr checkout";
      };
    };
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
    ignores = [ ".DS_Store" "*.log*" "node_modules" ".elixir_ls" ".direnv" ];
    includes = [{ path = "~/.gitconfig_local"; }];
    delta = { enable = true; };
  };
}
