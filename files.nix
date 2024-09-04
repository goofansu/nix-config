{ pkgs, ... }:

{
  home.file = {
    ".gemrc".text = "gem: --no-document";
    ".xrayconfig".text =
      ":editor: '/etc/profiles/per-user/james/bin/emacsclient -s gui -nc $file'";

    # Dictionaries for jinx
    ".config/enchant/hunspell/en_US.aff".source =
      "${pkgs.hunspellDicts.en_US}/share/hunspell/en_US.aff";
    ".config/enchant/hunspell/en_US.dic".source =
      "${pkgs.hunspellDicts.en_US}/share/hunspell/en_US.dic";
    ".config/enchant/hunspell/en_GB.aff".source =
      "${pkgs.hunspellDicts.en_GB-ise}/share/hunspell/en_GB.aff";
    ".config/enchant/hunspell/en_GB.dic".source =
      "${pkgs.hunspellDicts.en_GB-ise}/share/hunspell/en_GB.dic";
  };
}
