{ pkgs, ... }:

{
  programs.fzf.enable = true;
  programs.htop.enable = true;
  programs.jq.enable = true;
  programs.pandoc.enable = true;
  programs.password-store.enable = true;
  programs.tealdeer.enable = true;
  programs.zoxide.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

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

  programs.exa = {
    enable = true;
    enableAliases = true;
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
      confirm_os_window_close = 1;
      cursor_blink_interval = 0;
      cursor_shape = "block";
      enabled_layouts = "splits, stack";
      macos_option_as_alt = "left";
      macos_traditional_fullscreen = "yes";
      tab_bar_style = "powerline";
      window_padding_width = 4;
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
