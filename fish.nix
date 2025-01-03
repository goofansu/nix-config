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
    };
  };
}
