{ pkgs, ... }:

{
  # Fish enables this for completions, but Home Manager 26.05 sets programs.man.package to null on Darwin.
  programs.man.generateCaches = false;

  programs.fish = {
    enable = true;
    shellInit = ''
      set -U hydro_multiline true;
      set -gx RUBYOPT "-W0";
      set -gx BASH_COMPAT 50;
      set -gx NODE_NO_WARNINGS 1;
      set -gx TRY_PATH "~/scratch";
    '';
    interactiveShellInit = ''
      if set -q REX_BIN_DIR
          fish_add_path --path --prepend --move $REX_BIN_DIR
      end
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
      e = {
        description = "Edit file using Emacs GUI";
        body = "emacsclient -nc -s gui $argv";
      };
      cx = {
        description = "Claude Code in dangerous mode";
        body = "claude --dangerously-skip-permissions $argv";
      };
      t = {
        description = "Attach to Tmux, or start a new session if none is running";
        body = "tmux attach; or tmux new -s Work";
      };
      gpg-export-armor = {
        description = "Select and export an ASCII-armored GPG public key";
        body = ''
          gpg --list-secret-keys --with-colons \
            | awk -F: '$1 == "sec" { key = $5 } $1 == "uid" && key != "" { print key "\t" $10; key = "" }' \
            | fzf --prompt="GPG key: " \
            | read -l key uid
          or return 0

          gpg --armor --export-options export-minimal --export $key
        '';
      };
    };
  };

  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      theme = "modus-vivendi";
      font-size = 16;
      font-thicken = true;
      font-family = "Aporetic Sans Mono";
      macos-option-as-alt = true;
      cursor-style-blink = false;
      shell-integration-features = "cursor,sudo,title,ssh-env,ssh-terminfo";
      command = "${pkgs.fish}/bin/fish";
      window-inherit-working-directory = false;
      split-inherit-working-directory = true;
      tab-inherit-working-directory = true;
      keybind = [
        "global:cmd+ctrl+backquote=toggle_quick_terminal"
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
