{
  # Auto upgrade nix package and the daemon service
  services.nix-daemon.enable = true;

  # Create fish configs that loads the nix-darwin environment
  programs.fish.enable = true;

  # Used for backwards compatibility of nix-darwin
  system.stateVersion = 4;

  # Nix
  nix = {
    settings = {
      # Enable the Nix flakes feature
      experimental-features = "nix-command flakes";

      # Add myself to trusted-users to work with direnv
      trusted-users = [
        "root"
        "james"
      ];
    };

    registry = {
      flake-templates = {
        from = {
          id = "goofansu";
          ref = "templates";
          type = "indirect";
        };
        to = {
          type = "git";
          url = "https://github.com/goofansu/flake-templates.git";
        };
      };
    };
  };

  # Homebrew
  homebrew = {
    enable = true;
    casks = [
      "1password"
      "alfred"
      "anki"
      "bitwarden"
      "calibre"
      "chromedriver"
      "claude"
      "cleanshot"
      "cursor"
      "dash"
      "dropbox"
      "ghostty"
      "google-chrome"
      "hey"
      "livebook"
      "obs"
      "ollama"
      "orbstack"
      "pdf-expert"
      "pixelsnap"
      "postman"
      "prince"
      "rapidapi"
      "rectangle"
      "rubymine"
      "slack"
      "viscosity"
      "zoom"
    ];
  };
}
