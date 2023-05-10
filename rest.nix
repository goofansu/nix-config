{ pkgs, ... }:

{
  programs.fzf.enable = true;
  programs.htop.enable = true;
  programs.jq.enable = true;
  programs.pandoc.enable = true;

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
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "xterm-256color";
  };
}
