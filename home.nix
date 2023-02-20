{ pkgs, ... }:

{
  home.username = "james";
  home.homeDirectory = "/Users/james";
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.gh = {
    enable = true;
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
  };

  programs.fzf = {
    enable = true;
  };

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
  };

  home.file.".asdfrc".text = "legacy_version_file = yes";
  home.file.".gemrc".text = "gem: --no-document";
  home.file.".xrayconfig".text = ":editor: '/opt/homebrew/bin/emacsclient -s gui -c $file'";

  imports = [ ./packages.nix ./fish.nix ./git.nix ];
}
