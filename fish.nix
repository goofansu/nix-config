{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    shellInit = ''
      set -U hydro_multiline true;
    '';
    interactiveShellInit = ''
      if set -q GHOSTTY_RESOURCES_DIR
        source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
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
}
