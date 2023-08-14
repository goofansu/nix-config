{ lib, ... }: {
  home.username = lib.mkForce "james";
  home.homeDirectory = lib.mkForce "/Users/james";
  home.stateVersion = "23.05";
  programs.home-manager.enable = true;

  imports = [
    ./packages.nix
    ./fonts.nix
    ./files.nix
    ./envs.nix
    ./emacs.nix
    ./bash.nix
    ./fish.nix
    ./git.nix
    ./gpg.nix
    ./rest.nix
  ];
}
