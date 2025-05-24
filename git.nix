{ pkgs, pkgs-unstable, ... }:

{
  programs.gh = {
    enable = true;
    package = pkgs-unstable.gh;
    settings = {
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
      key = "3C2DE0F1FB93D0EE";
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
    ];
    includes = [ { path = "~/.gitconfig_local"; } ];
    difftastic = {
      enable = true;
    };
  };
}
