{ pkgs, ... }:

{
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      aliases = {
        clone = "repo clone";
        co = "pr checkout";
      };
    };
  };

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
      signByDefault = true;
      signer = "${pkgs.gnupg}/bin/gpg";
    };
    ignores = [
      ".DS_Store"
      "*.log*"
      "node_modules"
      ".elixir_ls" # next-ls
      ".claude/*.local.json" # local .claude/settings.json
      ".claude/worktrees" # claude worktrees location
      "CLAUDE.local.md" # local CLAUDE.md
      ".issues" # gh-issue-sync directory
      ".pi" # local .pi directory
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

  programs.difftastic = {
    enable = true;
    git.enable = true;
  };

  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        theme = {
          activeBorderColor = [ "#89b4fa" "bold" ];
          inactiveBorderColor = [ "#a6adc8" ];
          searchingActiveBorderColor = [ "#f9e2af" ];
          optionsTextColor = [ "#89b4fa" ];
          selectedLineBgColor = [ "#313244" ];
          inactiveViewSelectedLineBgColor = [ "#6c7086" ];
          cherryPickedCommitFgColor = [ "#89b4fa" ];
          cherryPickedCommitBgColor = [ "#45475a" ];
          markedBaseCommitFgColor = [ "#89b4fa" ];
          markedBaseCommitBgColor = [ "#f9e2af" ];
          unstagedChangesColor = [ "#f38ba8" ];
          defaultFgColor = [ "#cdd6f4" ];
        };
        authorColors = {
          "*" = "#b4befe";
        };
      };
      git = {
        autoFetch = false;
        pagers = [
          {
            externalDiffCommand = "difft --color=always --display=inline --background=dark";
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
            gh search prs {{.SelectedLocalCommit.Sha}} --sort created --order asc --limit 1 --json number --jq ".[] | .number" | xargs gh pr view -w
          '';
          context = "commits";
          description = "Browse pull request of selected commit";
        }
      ];
    };
  };
}
