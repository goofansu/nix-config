{
  home.sessionPath = [ "$HOME/.emacs.d/bin" ];

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";

    # editor
    EDITOR = "emacsclient -s term -t";
    VISUAL = "emacsclient -s term -t";

    # Emacs server name
    EMACS_SERVER_NAME = "gui";

    # Erlang
    KERL_BUILD_DOCS = "yes";
    ERL_AFLAGS = "-kernel shell_history enabled";

    # quiet direnv
    DIRENV_LOG_FORMAT = "";
  };
}
