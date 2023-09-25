{ pkgs, ... }:

{
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
      copy_on_select = "yes";
      cursor_blink_interval = 0;
      cursor_shape = "block";
      enabled_layouts = "splits, stack";
      macos_option_as_alt = "left";
      macos_traditional_fullscreen = "yes";
      scrollback_pager_history_size = 20;
      tab_bar_style = "powerline";
      window_padding_width = 4;
    };
    extraConfig = ''
      action_alias launch_window launch --type window --cwd current
    '';
    keybindings = {
      "cmd+]" = "next_window";
      "cmd+0x1e" = "next_window";
      "cmd+[" = "previous_window";
      "cmd+0x21" = "previous_window";
      "cmd+d" = "launch_window --location vsplit";
      "shift+cmd+d" = "launch_window --location hsplit";
      "shift+cmd+t" = "detach_window new-tab";
      "shift+cmd+Enter" = "toggle_layout stack";
    };
  };
}
