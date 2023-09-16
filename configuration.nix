{
  # the stateVersion of nix-darwin
  system.stateVersion = 4;

  # Make sure the nix daemon always runs
  services.nix-daemon.enable = true;

  # Creates a fish configuration sourcing needed environment changes
  programs.fish.enable = true;

  # Enable the flakes feature
  nix.settings.experimental-features = "nix-command flakes";

  # Add myself to trusted-users
  nix.settings.trusted-users = [ "root" "james" ];

  # Add my flakes templates to nix registry
  nix.registry.nix-templates = {
    from = {
      id = "goofansu";
      ref = "templates";
      type = "indirect";
    };
    to = {
      type = "git";
      url = "https://git.sr.ht/~goofansu/nix-templates";
    };
  };

  # Allow installing unfree packages
  nixpkgs.config.allowUnfree = true;

  # Homebrew
  homebrew.enable = true;
  homebrew.onActivation.cleanup = "uninstall";
  homebrew.casks = [
    "1password"
    "anki"
    "arc"
    "cleanshot"
    "dash"
    "deepl"
    "google-chrome"
    "hey"
    "mysqlworkbench"
    "postman"
    "prince"
    "raycast"
    "rapidapi"
    "slack"
    "viscosity"
    "zoom"
    "zotero"
  ];
}
