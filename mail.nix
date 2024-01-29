{ config, pkgs, ... }:

{
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
    };
  };

  programs = {
    mbsync.enable = true;
    msmtp.enable = true;
  };
}
