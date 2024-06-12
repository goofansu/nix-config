{ config, ... }:

{
  programs.gpg = {
    enable = true;
    publicKeys = [
      {
        source = ./gpg/pubkey.asc;
        trust = "ultimate";
      }
      {
        source = ./gpg/sr.ht_pubkey.asc;
        trust = "full";
      }
    ];
  };

  home.file.".gnupg/gpg-agent.conf".text = ''
    default-cache-ttl 28800
    max-cache-ttl 86400
  '';

  programs.password-store = {
    enable = true;
    settings = {
      PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
      PASSWORD_STORE_KEY = "3C2DE0F1FB93D0EE";
    };
  };
}
