{ pkgs, ... }:

{
  home.file = {
    ".gemrc".text = "gem: --no-document";
    ".npmrc".text = "prefix=~/.npm-global";
    ".xrayconfig".text = ":editor: '/etc/profiles/per-user/james/bin/emacsclient -s gui -nc $file'";
    ".config/ghostty/config".text = ''
      font-size = 16
      font-thicken = true
      macos-option-as-alt = true
      cursor-style-blink = false
      shell-integration-features = no-cursor
      command = ${pkgs.fish}/bin/fish

      # Theme: modus-vivendi
      # Description: XTerm port of modus-vivendi (Modus themes for GNU Emacs)
      # Author: Protesilaos Stavrou, <https://protesilaos.com>
      background = #000000
      foreground = #ffffff
      palette = 0=#000000
      palette = 1=#ff8059
      palette = 2=#44bc44
      palette = 3=#d0bc00
      palette = 4=#2fafff
      palette = 5=#feacd0
      palette = 6=#00d3d0
      palette = 7=#bfbfbf
      palette = 8=#595959
      palette = 9=#ef8b50
      palette = 10=#70b900
      palette = 11=#c0c530
      palette = 12=#79a8ff
      palette = 13=#b6a0ff
      palette = 14=#6ae4b9
      palette = 15=#ffffff
    '';

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
