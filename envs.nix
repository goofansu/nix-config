{ config, ... }:

{
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";

    EDITOR = "vi";
    VISUAL = "vi";

    # Enable shell history for Elixir IEx
    ERL_AFLAGS = "-kernel shell_history enabled";
  };

  home.sessionPath = [
    "/opt/homebrew/bin" # brew
    "/opt/homebrew/sbin" # brew
    "${config.home.homeDirectory}/.local/bin" # uv tools
    "${config.home.homeDirectory}/.npm-global/bin" # npm tools
    "${config.home.homeDirectory}/go/bin" # go tools
  ];
}
