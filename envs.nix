{ config, ... }:

{
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";

    EDITOR = "vi";
    VISUAL = "vi";

    # Enable shell history for Elixir IEx
    ERL_AFLAGS = "-kernel shell_history enabled";

    # Set uv run to always load .env
    UV_ENV_FILE = ".env";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
  ];
}
