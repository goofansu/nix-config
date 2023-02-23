{
  home.username = "james";
  home.homeDirectory = "/Users/james";
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;

  home.sessionVariables = {
    DIRENV_LOG_FORMAT = "";
  };

  fonts.fontconfig.enable = true;

  imports = [
    ./packages.nix
    ./files.nix
    ./emacs.nix
    ./fish.nix
    ./git.nix
    ./rest.nix
  ];
}
