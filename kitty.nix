{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    themeFile = "Modus_Vivendi";
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
      "shift+cmd+d" = "close_window_with_confirmation";
    };
  };
}
