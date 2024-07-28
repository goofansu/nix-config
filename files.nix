{ pkgs, ... }:

{
  home.file.".gemrc".text = "gem: --no-document";
  home.file.".xrayconfig".text =
    ":editor: '/etc/profiles/per-user/james/bin/emacsclient -s gui -nc $file'";
  home.file.".config/enchant/hunspell/".source =
    "${pkgs.hunspellDicts.en_US}/share/hunspell/";
}
