{ pkgs, ... }:

let
  gmailSettings = {
    imap = {
      host = "imap.gmail.com";
      port = 993;
    };
    smtp = {
      host = "smtp.gmail.com";
      port = 587;
      tls.useStartTls = true;
    };

    mbsync = {
      enable = true;
      create = "both";
      expunge = "both";
      patterns = [
        "*"
        "[Gmail]*"
      ];
    };
    notmuch.enable = true;
    msmtp.enable = true;
  };
in
{
  accounts.email = {
    maildirBasePath = ".mail";
    accounts = {
      home = {
        primary = true;
        address = "goofan.su@gmail.com";
        userName = "goofan.su@gmail.com";
        realName = "Yejun Su";
        passwordCommand = "${pkgs.pass}/bin/pass goofan.su@gmail.com";
        maildir = {
          path = "Home";
        };
      } // gmailSettings;
      work = {
        address = "james.su@managebac.com";
        userName = "james.su@managebac.com";
        realName = "James Su";
        passwordCommand = "${pkgs.pass}/bin/pass james.su@managebac.com";
        maildir = {
          path = "Work";
        };
      } // gmailSettings;
    };
  };

  programs.mbsync.enable = true;
  programs.msmtp.enable = true;
  programs.notmuch = {
    enable = true;
    hooks = {
      preNew = "${pkgs.isync}/bin/mbsync -a";
    };
  };
}
