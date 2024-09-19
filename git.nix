{ pkgs, ... }:

{
  programs.gh = {
    enable = true;
    settings = {
      aliases = {
        clone = "repo clone";
        co = "pr checkout";
      };
    };
  };

  programs.git = rec {
    enable = true;
    userName = "Yejun Su";
    userEmail = "goofan.su@gmail.com";
    aliases = {
      br = "branch";
      ci = "commit";
      co = "checkout";
    };
    signing = {
      key = "3C2DE0F1FB93D0EE";
      signByDefault = true;
      gpgPath = "${pkgs.gnupg}/bin/gpg";
    };
    extraConfig = {
      init = { defaultBranch = "main"; };
      merge = { conflictStyle = "diff3"; };
      pull = { rebase = true; };
      github = { user = "goofansu"; };
      advice = { detachedHead = false; };
      sendemail = {
        smtpserver = "smtp.gmail.com";
        smtpuser = userEmail;
        smtpencryption = "tls";
        smtpserverport = 587;
      };
    };
    ignores = [ ".DS_Store" "*.log*" "node_modules" ".elixir_ls" ];
    includes = [{ path = "~/.gitconfig_local"; }];
    difftastic = { enable = true; };
  };
}
