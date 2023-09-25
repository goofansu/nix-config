{ lib, ... }: {
  home.username = lib.mkForce "james";
  home.homeDirectory = lib.mkForce "/Users/james";
  home.stateVersion = "23.11";
  programs.home-manager.enable = true;

  imports = [
    ./packages.nix
    ./fonts.nix
    ./files.nix
    ./envs.nix
    ./emacs.nix
    ./fish.nix
    ./term.nix
    ./mail.nix
    ./git.nix
    ./gpg.nix
    ./rest.nix
  ];
}
