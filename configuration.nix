{ pkgs, ... }:

{
  # Create fish configs that loads the nix-darwin environment
  programs.fish.enable = true;

  # Used for backwards compatibility of nix-darwin
  system = {
    stateVersion = 4;
    primaryUser = "james";
  };

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

  # LaunchAgents
  launchd = {
    user = {
      agents = {
        notmuch-new = {
          command = "${pkgs.notmuch}/bin/notmuch new";
          serviceConfig = {
            RunAtLoad = true;
            StartInterval = 900;
            StandardOutPath = "/tmp/notmuchnew.out.log";
            StandardErrorPath = "/tmp/notmuchnew.err.log";
          };
        };
      };
      envVariables = {
        # FIXME remove hard-coded value
        PATH = "/etc/profiles/per-user/james/bin:$PATH";
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
      "cleanshot"
      "cursor"
      "dropbox"
      "ghostty"
      "google-chrome"
      "httpie"
      "livebook"
      "obs"
      "orbstack"
      "pdf-expert"
      "postman"
      "prince"
      "racket"
      "raindropio"
      "rectangle"
      "rubymine"
      "slack"
      "viscosity"
      "zoom"
    ];
  };
}
