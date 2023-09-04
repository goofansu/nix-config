{ pkgs, ... }:

{
  home.file.".gemrc".text = "gem: --no-document";
  home.file.".xrayconfig".text =
    ":editor: '/etc/profiles/per-user/james/bin/emacsclient -s gui -nc $file'";
}
