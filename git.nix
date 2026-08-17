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
    };
  };

  programs.delta.enable = true;
}
