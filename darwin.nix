{
  # Make sure the nix daemon always runs
  services.nix-daemon.enable = true;

  # Creates a fish configuration sourcing needed environment changes
  programs.fish.enable = true;

  # Enable the flakes feature
  nix.settings.experimental-features = "nix-command flakes";

  # Add my flakes templates to nix registry
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

  # Allow installing unfree packages
  nixpkgs.config.allowUnfree = true;

  # HomeManager
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.james = import ./home.nix;

  # Homebrew
  homebrew.enable = true;
  homebrew.onActivation.cleanup = "zap";
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
    "hey"
    "livebook"
    "notion"
    "prince"
    "raycast"
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
