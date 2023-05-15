{
  home.username = "james";
  home.homeDirectory = "/Users/james";
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;

  imports = [
    ./packages.nix
    ./files.nix
    ./envs.nix
    ./emacs.nix
    ./bash.nix
    ./fish.nix
    ./git.nix
    ./rest.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };
}
