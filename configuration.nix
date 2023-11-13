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
      trusted-users = [ "root" "james" ];
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
          url = "https://git.sr.ht/~goofansu/flake-templates";
        };
      };
    };
  };

  # Homebrew
  homebrew = {
    enable = true;
    onActivation = { cleanup = "uninstall"; };
    casks = [
      "1password"
      "anki"
      "arc"
      "cleanshot"
      "dash"
      "dropbox"
      "deepl"
      "google-chrome"
      "hey"
      "mysqlworkbench"
      "orbstack"
      "postman"
      "prince"
      "raycast"
      "rapidapi"
      "slack"
      "viscosity"
      "wechatwebdevtools"
      "zoom"
      "zotero"
    ];
  };
}
