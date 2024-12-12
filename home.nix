{ lib, ... }:
{
  home.username = lib.mkForce "james";
  home.homeDirectory = lib.mkForce "/Users/james";
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  imports = [
    ./packages.nix
    ./fonts.nix
    ./files.nix
    ./envs.nix
    ./emacs.nix
    ./kitty.nix
    ./fish.nix
    ./mail.nix
    ./git.nix
    ./gpg.nix
    ./rest.nix
  ];
}
