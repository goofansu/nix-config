{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    shellInit = ''
      set -U hydro_multiline true;
    '';
    plugins = with pkgs.fishPlugins; [
      {
        name = "hydro";
        src = hydro.src;
      }
      {
        name = "done";
        src = done.src;
      }
    ];
    functions = {
      rm = {
        description = "Ask before removing a file";
        body = "command rm -i $argv";
      };
      gco = {
        description = "Fuzzy find and checkout the selected pull request";
        body = "gh pr list $argv | fzf | awk '{print $1}' | read -l result; and gh co $result";
      };
      gcb = {
        description = "Fuzzy find and checkout the selected git branch";
        body = "git br | fzf | awk '{print $1}' | read -l result; and git co $result";
      };
      gcl = {
        description = "Fuzzy find and list commits of the selected git branch";
        body = "git br | fzf | awk '{print $1}' | read -l result; and git log --oneline --graph $result";
      };
      gcd = {
        description = "Fuzzy find and cd the selected git worktree";
        body = "git worktree list --porcelain | grep '^worktree ' | sed 's/^worktree //' | fzf | awk '{print $1}' | read -l result; and cd $result";
      };
    };
  };

  programs.ghostty = {
    enable = true;
    package = null;
    enableFishIntegration = true;
    settings = {
      theme = "modus-vivendi";
      font-size = 16;
      font-thicken = true;
      macos-option-as-alt = true;
      cursor-style-blink = false;
      shell-integration-features = "no-cursor,sudo,title,ssh-env,ssh-terminfo";
      command = "${pkgs.fish}/bin/fish";
      keybind = [
        "shift+enter=text:\\n" # newline
        "ctrl+shift+m=set_font_size:20" # medium
        "ctrl+shift+l=set_font_size:24" # large
      ];
    };
    themes = {
      modus-vivendi = {
        # Theme: modus-vivendi
        # Description: XTerm port of modus-vivendi (Modus themes for GNU Emacs)
        # Author: Protesilaos Stavrou, <https://protesilaos.com>
        background = "#000000";
        foreground = "#ffffff";
        palette = [
          "0=#000000"
          "1=#ff8059"
          "2=#44bc44"
          "3=#d0bc00"
          "4=#2fafff"
          "5=#feacd0"
          "6=#00d3d0"
          "7=#bfbfbf"
          "8=#595959"
          "9=#ef8b50"
          "10=#70b900"
          "11=#c0c530"
          "12=#79a8ff"
          "13=#b6a0ff"
          "14=#6ae4b9"
          "15=#ffffff"
        ];
      };
    };
  };
}
