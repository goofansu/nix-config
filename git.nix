{ pkgs, ... }:

{
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      aliases = {
        clone = "repo clone";
        co = "pr checkout";
      };
    };
  };

  programs.git = {
    enable = true;
    userEmail = "goofan.su@gmail.com";
    userName = "Yejun Su";
    aliases = {
      br = "branch";
      ci = "commit";
      co = "checkout";
    };
    signing = {
      key = "AD03A563F321CA44";
      signByDefault = true;
      signer = "${pkgs.gnupg}/bin/gpg";
    };
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      merge = {
        conflictStyle = "diff3";
      };
      pull = {
        rebase = true;
      };
      push = {
        autoSetupRemote = true;
      };
      github = {
        user = "goofansu";
      };
      advice = {
        detachedHead = false;
      };
      sendemail = {
        smtpserver = "smtp.gmail.com";
        smtpuser = "goofan.su@gmail.com";
        smtpencryption = "tls";
        smtpserverport = 587;
      };
    };
    ignores = [
      ".DS_Store"
      "*.log*"
      "node_modules"
      ".elixir_ls"
      ".claude/*.local.json"
      "CLAUDE.local.md"
    ];
    includes = [ { path = "~/.gitconfig_local"; } ];
    difftastic = {
      enable = true;
    };
  };
}
