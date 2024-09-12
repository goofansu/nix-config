{ pkgs, ... }:

{
  programs.eza.enable = true;
  programs.fd.enable = true;
  programs.fzf.enable = true;
  programs.htop.enable = true;
  programs.jq.enable = true;
  programs.pandoc.enable = true;
  programs.ripgrep.enable = true;
  programs.zoxide.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://api.atuin.sh";
      search_mode = "prefix";
    };
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
      style = "plain";
    };
  };

  programs.tealdeer = {
    enable = true;
    settings = {
      display = { compact = true; };
      updates = { auto_update = true; };
    };
  };

  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    extensions = with pkgs.vscode-extensions; [ mkhl.direnv shopify.ruby-lsp ];
    userSettings = {
      "editor.fontSize" = 16;
      "extensions.ignoreRecommendations" = true;
      "rubyLsp.formatter" = "none";
      "window.autoDetectColorScheme" = true;
      "workbench.activityBar.location" = "top";
      "workbench.colorTheme" = "Default Light Modern";
    };
  };
}
