{ pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    package = pkgs.fzf.overrideAttrs (final: prev: {
      postInstall = (prev.postInstall or "") + ''
        cat << EOF > $out/share/fish/vendor_conf.d/load-fzf-key-bindings.fish
          status is-interactive; or exit 0
          fzf_key_bindings
        EOF
      '';
    });
  };

  programs.htop.enable = true;
  programs.jq.enable = true;
  programs.pandoc.enable = true;
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

  programs.eza = {
    enable = true;
    enableAliases = true;
  };

  programs.tealdeer = {
    enable = true;
    settings = {
      display = { compact = true; };
      updates = { auto_update = true; };
    };
  };
}
