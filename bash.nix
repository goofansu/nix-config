{
  programs.bash = {
    enable = true;
    enableCompletion = false;
    shellOptions = [];
    sessionVariables = {
      BASH_SILENCE_DEPRECATION_WARNING = 1;
      PATH = "/opt/homebrew/sbin/:/opt/homebrew/bin:$PATH";
    };
    profileExtra = ''
      . $HOME/.nix-profile/share/asdf-vm/asdf.sh
    '';
  };
}
