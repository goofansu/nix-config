{ config, ... }:

{
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";

    EDITOR = "vi";
    VISUAL = "vi";

    # Enable shell history for Elixir IEx
    ERL_AFLAGS = "-kernel shell_history enabled";

    # uv: https://docs.astral.sh/uv/configuration/environment/
    UV_ENV_FILE = ".env";
    UV_PYTHON = "3.12";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin" # uv puts tool executables here
  ];
}
