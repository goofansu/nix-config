{ config, pkgs, ... }:

let
  name = "Yejun Su";
  email = "goofan.su@gmail.com";
in
{
  accounts.email = {
    maildirBasePath = ".mail";
    accounts = {
      gmail = {
        primary = true;
        address = "${email}";
        userName = "${email}";
        realName = "${name}";
        passwordCommand = "${pkgs.pass}/bin/pass ${email}";
        maildir = { path = "."; };
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
