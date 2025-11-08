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

    stdlib = ''
      : ''${XDG_CACHE_HOME:=$HOME/.cache}
      declare -A direnv_layout_dirs

      direnv_layout_dir() {
        echo "''${direnv_layout_dirs[$PWD]:=$(
          echo -n "$XDG_CACHE_HOME"/direnv/layouts/
          echo -n "$PWD" | sha1sum | cut -d ' ' -f 1
        )}"
      }
    '';
  };

  programs.atuin = {
    enable = true;
    settings = {
      filter_mode_shell_up_key_binding = "session";
      sync_address = "https://atuin.yejun.dev";
      auto_sync = true;
    };
  };
}
