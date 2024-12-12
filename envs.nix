{
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";

    EDITOR = "emacsclient -s term -t";
    VISUAL = "emacsclient -s term -t";

    # Quiet direnv
    DIRENV_LOG_FORMAT = "";

    # Enable shell history for Elixir IEx
    ERL_AFLAGS = "-kernel shell_history enabled";
  };

  home.sessionPath = [ "$HOME/Library/Python/3.9/bin" ];
}
