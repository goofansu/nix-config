{ lib, ... }: {
  home.username = lib.mkForce "james";
  home.homeDirectory = lib.mkForce "/Users/james";
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  imports = [
    ./packages.nix
    ./fonts.nix
    ./files.nix
    ./envs.nix
    ./emacs.nix
    ./term.nix
    ./mail.nix
    ./git.nix
    ./gpg.nix
    ./rest.nix
  ];
}
