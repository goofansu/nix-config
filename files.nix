{ pkgs, ... }:

{
  home.file = {
    ".gemrc".text = "gem: --no-document";
    ".npmrc".text = "prefix=~/.npm-global";
    ".xrayconfig".text = ":editor: '/opt/homebrew/bin/zed'";
    ".config/ghostty/config".source = ./files/ghostty/config;
    ".config/zed/tasks.json".source = ./files/zed/tasks.json;
    ".config/zed/keymap.json".source = ./files/zed/keymap.json;

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
