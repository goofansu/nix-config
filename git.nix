{ config, pkgs, pkgs-unstable, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      advice = {
        detachedHead = false;
      };
      alias = {
        br = "branch";
        ci = "commit";
        co = "checkout";
      };
      commit = {
        gpgSign = true;
      };
      github = {
        user = "goofansu";
      };
      init = {
        defaultBranch = "main";
      };
      merge = {
        conflictStyle = "diff3";
      };
      pull = {
        rebase = true;
      };
      push = {
        autoSetupRemote = true;
      };
      user = {
        name = "Yejun Su";
        email = "goofan.su@gmail.com";
      };
    };
    signing = {
      key = "AD03A563F321CA44";
      signer = "${pkgs.gnupg}/bin/gpg";
    };
    ignores = [
      ".DS_Store"
      "*.log*"
      "node_modules"
      ".pi/"
      ".codex/"
      ".claude/"
      ".obsidian/"
      ".scratch/"
      ".humanlayer/"
    ];
    includes = [
      {
        condition = "gitdir:~/work/";
        contents = {
          user = {
            name = "James Su";
            email = "james.su@managebac.com";
            signingKey = "911B52D71F8AEBD9";
          };
        };
      }
    ];
  };

  programs.gh = {
    enable = true;
    package = pkgs.gh;
    settings = {
      git_protocol = "ssh";
    };
  };

  programs.delta = {
    enable = true;
    package = pkgs-unstable.delta;
  };
  programs.lazygit = {
    enable = true;
    package = pkgs-unstable.lazygit;
    settings = {
      promptToReturnFromSubprocess = false;
      gui.colorScheme = "auto";
      git = {
        autoFetch = false;
        diffRenderers = [
          {
            command = "delta --{{colorScheme}} --paging=never";
          }
        ];
      };
      customCommands = [
        {
          key = "G";
          command = "gh pr view -w {{.SelectedLocalBranch.Name}}";
          context = "localBranches";
          description = "Browse pull request of selected branch";
        }
        {
          key = "G";
          command = ''
            gh api repos/{owner}/{repo}/commits/{{.SelectedLocalCommit.Sha}}/pulls --jq ".[0].number" | xargs gh pr view -w
          '';
          context = "commits";
          description = "Browse pull request of selected commit";
        }
      ];
    };
  };
}
