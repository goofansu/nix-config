{
  home.username = "james";
  home.homeDirectory = "/Users/james";
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;

  home.sessionVariables = {
    DIRENV_LOG_FORMAT = "";
  };

  imports = [
    ./files.nix
    ./fish.nix
    ./git.nix
    ./packages.nix
    ./rest.nix
  ];
}
