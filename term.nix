{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    theme = "Modus Vivendi";
    font = {
      name = "Iosevka Comfy Fixed";
      size = 18;
    };
    shellIntegration = {
      mode = "no-cursor";
      enableFishIntegration = true;
    };
    settings = {
      # Cursor
      cursor_blink_interval = 0;

      # Scrollback
      scrollback_pager_history_size = 40;

      # Mouse
      copy_on_select = "clipboard";

      # Window
      confirm_os_window_close = 1;

      # Advanced
      shell = "${pkgs.fish}/bin/fish";

      # OS specific tweaks
      macos_option_as_alt = "both";
      macos_traditional_fullscreen = "yes";
    };
    keybindings = {
      "cmd+enter" = "launch --cwd=current";
      "shift+cmd+enter" = "toggle_layout stack";
    };
  };

  programs.fish = {
    enable = true;
    shellInit = ''
      set -U hydro_multiline true;
    '';
    plugins = [{
      name = "hydro";
      src = pkgs.fishPlugins.hydro.src;
    }];
    functions = {
      cat = {
        description = "A cat(1) clone with wings";
        body = "if command -sq bat; bat $argv; end";
      };
      rm = {
        description = "Ask before removing a file";
        body = "command rm -i $argv";
      };

      # Emacs
      e = {
        description = "The Emacs version of vi";
        body = "emacsclient -s term -nw -a '' $argv";
      };
      ekill = {
        description = "Kill the term Emacs server";
        body = ''
          emacsclient -s term -e "(kill-emacs)"
        '';
      };

      # Fuzzy find everything!
      fssh = {
        description = "Fuzzy find and ssh into a host";
        body = ''
          rg --ignore-case '^host [^*]' ~/.ssh/* | cut -d ' ' -f 2 | fzf | read -l result; and ${pkgs.kitty}/bin/kitten ssh "$result"
        '';
      };
    };
  };
}
