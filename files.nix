{ pkgs, ... }:

{
  home.file = {
    ".gemrc".text = "gem: --no-document";
    ".xrayconfig".text = ":editor: '/opt/homebrew/bin/zed'";
  };
}
