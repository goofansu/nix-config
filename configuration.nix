{ pkgs, ... }:

{
  # Create fish configs that loads the nix-darwin environment
  programs.fish.enable = true;

  # Used for backwards compatibility of nix-darwin
  system = {
    stateVersion = 5;
    primaryUser = "james";
  };

  # Nix
  nix = {
    settings = {
      # Enable the Nix flakes feature
      experimental-features = "nix-command flakes";
      accept-flake-config = true;

      # Add myself to trusted-users to work with direnv
      trusted-users = [
        "root"
        "james"
      ];
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
      "calibre"
      "cleanshot"
      "firefox"
      "ghostty"
      "google-chrome"
      "marked-app"
      "ngrok"
      "obs"
      "orbstack"
      "prince"
      "rapidapi"
      "rectangle"
      "slack"
      "spotify"
      "tailscale-app"
      "zed"
      "zoom"
      "zotero"
    ];
  };
}
