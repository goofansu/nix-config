{
  programs.bash = {
    enable = true;
    enableCompletion = false;
    shellOptions = [ ];
    sessionVariables = { BASH_SILENCE_DEPRECATION_WARNING = 1; };
  };
}
