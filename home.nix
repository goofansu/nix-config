{ lib, ... }:
{
  home.username = lib.mkForce "james";
  home.homeDirectory = lib.mkForce "/Users/james";
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  imports = [
    ./packages.nix
    ./fonts.nix
    ./files.nix
    ./envs.nix
    ./emacs.nix
    ./fish.nix
    ./mail.nix
    ./git.nix
    ./gpg.nix
    ./rest.nix
    ./neovim.nix
  ];
}
