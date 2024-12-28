{
  programs.bat.enable = true;
  programs.btop.enable = true;
  programs.eza.enable = true;
  programs.fastfetch.enable = true;
  programs.fd.enable = true;
  programs.fzf.enable = true;
  programs.htop.enable = true;
  programs.jq.enable = true;
  programs.pandoc.enable = true;
  programs.ripgrep.enable = true;
  programs.tealdeer.enable = true;
  programs.zoxide.enable = true;

  programs.direnv = {
    enable = true;
    silent = true;
    nix-direnv.enable = true;
  };

  programs.atuin = {
    enable = true;
    settings = {
      filter_mode_shell_up_key_binding = "session";
    };
  };
}
