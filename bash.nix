{ pkgs, ... }:

{
  programs.bash = {
    enable = true;
    enableCompletion = false;
    shellOptions = [ ];
    sessionVariables = { BASH_SILENCE_DEPRECATION_WARNING = 1; };
    profileExtra = ''
      . ${pkgs.asdf-vm}/share/asdf-vm/asdf.sh
    '';
  };
}
