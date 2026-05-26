{ pkgs, ... }:

{
  home.file = {
    ".gemrc".text = "gem: --no-document";
    ".npmrc".text = "prefix=~/.npm-global";
    ".xrayconfig".text = ":editor: '/opt/homebrew/bin/zed'";
  };
}
