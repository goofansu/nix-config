{
  system.stateVersion = 4;
  programs.fish.enable = true;

  services.nix-daemon.enable = true;
  nix.settings.experimental-features = "nix-command flakes";
  nix.registry.nix-templates = {
    from = {
      id = "goofansu";
      ref = "templates";
      type = "indirect";
    };
    to = {
      type = "git";
      url = "https://codeberg.org/goofansu/nix-templates";
    };
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # Homebrew
  homebrew.enable = true;
  homebrew.taps = [
    "railwaycat/emacsmacport"
    {
      name = "lencx/chatgpt";
      clone_target = "https://github.com/lencx/ChatGPT.git";
    }
  ];
  homebrew.casks = [
    "1password"
    "alfred"
    "anki"
    "arc"
    "cleanshot"
    "dash"
    "deepl"
    "dropbox"
    "emacs-mac"
    "google-chrome"
    "gpg-suite"
    "hey"
    "iterm2"
    "livebook"
    "notion"
    "postman"
    "prince"
    "rectangle"
    "slack"
    "spotify"
    "viscosity"
    "zoom"
    {
      name = "chatgpt";
      args = { no_quarantine = true; };
    }
  ];
}
