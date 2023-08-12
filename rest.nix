{ pkgs, ... }:

{
  programs.fzf.enable = true;
  programs.zoxide.enable = true;

  programs.atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
      style = "plain";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.exa = {
    enable = true;
    enableAliases = true;
  };

  programs.tmux = {
    enable = false;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "xterm-256color";
  };

  programs.kitty = {
    enable = true;
    theme = "Dracula";
    font = {
      name = "JetBrains Mono";
      size = 16;
    };
    darwinLaunchOptions = [ "--listen-on=unix:/tmp/kitty.sock" ];
    shellIntegration = {
      mode = "no-cursor";
      enableFishIntegration = true;
    };
    settings = {
      shell = "${pkgs.fish}/bin/fish";
      allow_remote_control = "yes";
      cursor_blink_interval = 0;
      cursor_shape = "block";
      macos_option_as_alt = "left";
      macos_traditional_fullscreen = "yes";
      tab_bar_style = "powerline";
      enabled_layouts = "splits, stack";
    };
    extraConfig = ''
      action_alias launch_window launch --type window --cwd current
    '';
    keybindings = {
      "cmd+d" = "launch_window --location vsplit";
      "shift+cmd+d" = "launch_window --location hsplit";
      "shift+cmd+Enter" = "toggle_layout stack";
      "cmd+]" = "next_window";
      "cmd+[" = "previous_window";
    };
  };
}
