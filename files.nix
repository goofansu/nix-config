{
  home.file.".asdfrc".text = "legacy_version_file = yes";
  home.file.".gemrc".text = "gem: --no-document";
  home.file.".xrayconfig".text = ":editor: 'emacsclient -s gui -c $file'";
  home.file.".Brewfile".source = ./Brewfile;
  home.file.".Brewfile.lock.json".source = ./Brewfile.lock.json;
}
