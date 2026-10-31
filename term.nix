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
}
