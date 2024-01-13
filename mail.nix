{ config, pkgs, ... }:

let
  gmailSettings = {
    mbsync = {
      enable = true;
      create = "both";
      expunge = "both";
      patterns = [ "*" "[Gmail]*" ];
    };
    imap = {
      host = "imap.gmail.com";
      port = 993;
    };
    msmtp.enable = true;
    smtp = {
      host = "smtp.gmail.com";
      port = 587;
      tls.useStartTls = true;
    };
  };
in {
  accounts.email = {
    maildirBasePath = ".mail";
    accounts = {
      personal = {
        primary = true;
        address = "goofan.su@gmail.com";
        userName = "goofan.su@gmail.com";
        realName = "Yejun Su";
        passwordCommand = "${pkgs.pass}/bin/pass goofan.su@gmail.com";
        maildir = { path = "Personal"; };
      } // gmailSettings;
      work = {
        address = "james.su@managebac.com";
        userName = "james.su@managebac.com";
        realName = "James Su";
        passwordCommand = "${pkgs.pass}/bin/pass james.su@managebac.com";
        maildir = { path = "Work"; };
      } // gmailSettings;
    };
  };

  programs = {
    mbsync.enable = true;
    msmtp.enable = true;
  };
}
