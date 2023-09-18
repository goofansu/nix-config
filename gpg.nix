{ config, pkgs, pkgs-stable, ... }:

{
  programs.gpg = {
    enable = true;
    package = pkgs-stable.gnupg;
    publicKeys = [{
      source = ./gpg/pubkey.asc;
      trust = "ultimate";
    }];
  };

  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
    settings = {
      PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
      PASSWORD_STORE_KEY = "FB93D0EE";
    };
  };
}
