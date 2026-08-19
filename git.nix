{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

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
      ".pi"
      ".codex"
      ".claude"
      ".superpowers"
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

  programs.gh-dash = {
    enable = true;
    package = pkgs-unstable.gh-dash;
    settings.repoPaths = {
      "eduvo/*" = "${config.home.homeDirectory}/work/*";
      "goofansu/*" = "${config.home.homeDirectory}/code/*";
    };
    settings.keybindings = {
      prs = [
        {
          key = "ctrl+o";
          name = "open";
          command = ''
            # Require a local clone of the PR's repo
            set -l repo "{{.RepoPath}}"
            set -l origin (git -C "$repo" remote get-url origin 2>/dev/null)
            if not string match -q "*{{.RepoName}}*" "$origin"
                echo "No local clone of {{.RepoName}} at $repo"
                read -P "Press enter to continue"
                exit 1
            end

            # Open a Herdr workspace for the PR
            set -l pane (herdr workspace create --cwd "$repo" --label "#{{.PrNumber}} {{.HeadRefName}}" --focus | jq -r '.result.root_pane.pane_id')
            test -n "$pane"; or exit 1

            # Check out the PR worktree and start Claude Code in it
            herdr pane run "$pane" "wt switch pr:{{.PrNumber}} -x cx"
          '';
        }
      ];
      issues = [
        {
          key = "ctrl+o";
          name = "open";
          command = ''
            # Require a local clone of the issue's repo
            set -l repo "{{.RepoPath}}"
            set -l origin (git -C "$repo" remote get-url origin 2>/dev/null)
            if not string match -q "*{{.RepoName}}*" "$origin"
                echo "No local clone of {{.RepoName}} at $repo"
                read -P "Press enter to continue"
                exit 1
            end

            # Open a Herdr workspace for the issue
            set -l name (path basename "{{.RepoName}}")
            set -l pane (herdr workspace create --cwd "$repo" --label "#{{.IssueNumber}} $name" --focus | jq -r '.result.root_pane.pane_id')
            test -n "$pane"; or exit 1

            # Start Claude Code in the main clone, on the default branch,
            # naming the session after the issue title when it is available
            set -l title (gh issue view {{.IssueNumber}} --repo "{{.RepoName}}" --json title --jq .title 2>/dev/null)
            if test -n "$title"
                herdr pane run "$pane" "cx --name "(string escape -- $title)
            else
                herdr pane run "$pane" cx
            end
          '';
        }
      ];
    };
  };

  programs.delta.enable = true;
  programs.lazygit = {
    enable = true;
    settings = {
      promptToReturnFromSubprocess = false;
      gui = {
        theme = {
          activeBorderColor = [
            "#2fafff"
            "bold"
          ];
          inactiveBorderColor = [ "#646464" ];
          searchingActiveBorderColor = [ "#d0bc00" ];
          optionsTextColor = [ "#2fafff" ];
          selectedLineBgColor = [ "#303030" ];
          inactiveViewSelectedLineBgColor = [ "#1e1e1e" ];
          cherryPickedCommitFgColor = [ "#2fafff" ];
          cherryPickedCommitBgColor = [ "#1640b0" ];
          markedBaseCommitFgColor = [ "#2fafff" ];
          markedBaseCommitBgColor = [ "#7a6100" ];
          unstagedChangesColor = [ "#ff5f59" ];
          defaultFgColor = [ "#ffffff" ];
        };
        authorColors = {
          "*" = "#c6daff";
        };
      };
      git = {
        autoFetch = false;
        pagers = [
          {
            pager = "delta --dark --paging=never";
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
