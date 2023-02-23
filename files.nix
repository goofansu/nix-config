{
  home.file.".asdfrc".text = "legacy_version_file = yes";
  home.file.".bash_profile".text = ''
    export BASH_SILENCE_DEPRECATION_WARNING=1
    export PATH="/opt/homebrew/sbin/:/opt/homebrew/bin:$PATH"
    . "$HOME/.nix-profile/share/asdf-vm/asdf.sh"
  '';
  home.file.".gemrc".text = "gem: --no-document";
  home.file.".xrayconfig".text = ":editor: '~/.nix-profile/bin/emacsclient -s gui -c $file'";
}
