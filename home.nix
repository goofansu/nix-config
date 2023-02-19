{ pkgs, ... }: {
  home.username = "james";
  home.homeDirectory = "/Users/james";
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;

  home.packages = [];

  # As a rule of thumb, if it’s supported by home-manager,
  # install the program using programs.<program>.
  # If not, add it to home.packages.
  programs.git = {
    enable = true;
    includes = [{ path = "~/.config/nixpkgs/gitconfig"; }];
  };
}
