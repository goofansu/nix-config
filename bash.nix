{
  programs.bash = {
    enable = false;
    enableCompletion = false;
    shellOptions = [ ];
    sessionVariables = { BASH_SILENCE_DEPRECATION_WARNING = 1; };
  };
}
