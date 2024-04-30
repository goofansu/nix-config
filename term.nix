{ pkgs, ... }:

let
  kitty-select-tab = pkgs.writeShellApplication {
    name = "kitty-select-tab";
    runtimeInputs = with pkgs; [ kitty jq fzf gawk ];
    text = ''
      kitty @ ls \
        | jq -r '.[] | select(.is_active) | .tabs[] | select(.is_focused == false) | "\(.title)\t\(.id)"' \
        | fzf \
        | awk '{print $NF}' \
        | xargs -I % kitty @ focus-tab -m id:%
    '';
  };
in {
  programs.kitty = {
    enable = true;
    theme = "Dracula";
    font = {
      name = "Iosevka Comfy Fixed";
      size = 18;
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
      action_alias launch_overlay launch --type overlay --cwd current
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
      "cmd+g" = "launch_overlay ${kitty-select-tab}/bin/kitty-select-tab";
    };
  };
}
