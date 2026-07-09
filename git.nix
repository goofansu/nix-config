{ pkgs, pkgs-unstable, ... }:

let
  gh-ai = pkgs.stdenvNoCC.mkDerivation {
    pname = "gh-ai";
    version = "0-unstable";
    src = ./scripts/gh-ai.fish;
    nativeBuildInputs = [
      pkgs.fish
      pkgs.makeWrapper
    ];
    dontUnpack = true;
    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/bin/gh-ai
      patchShebangs $out/bin/gh-ai
      wrapProgram $out/bin/gh-ai \
        --prefix PATH : ${
          pkgs.lib.makeBinPath (
            with pkgs;
            [
              coreutils
              fish
              fzf
              gawk
              git
              gnused
              tmux
              pkgs-unstable.gh
            ]
          )
        }
      runHook postInstall
    '';
  };
in
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
    package = pkgs-unstable.gh;
    extensions = [ gh-ai ];
    settings = {
      git_protocol = "ssh";
    };
  };

  programs.gh-dash = {
    enable = true;
    package = pkgs-unstable.gh-dash;
    settings.prSections = [
      {
        title = "My pull requests";
        filters = "is:open author:@me";
      }
      {
        title = "Needs my review";
        filters = "is:open review-requested:@me";
      }
      {
        title = "Assigned";
        filters = "is:open assignee:@me";
      }
      {
        title = "Involved";
        filters = "is:open involves:@me -author:@me";
      }
    ];
    settings.issuesSections = [
      {
        title = "My issues";
        filters = "is:open author:@me";
      }
      {
        title = "Ready for agent";
        filters = "is:open assignee:@me label:ready-for-agent";
      }
      {
        title = "Assigned";
        filters = "is:open assignee:@me";
      }
      {
        title = "Involved";
        filters = "is:open involves:@me -author:@me";
      }
    ];
    settings.keybindings = {
      issues = [
        {
          key = "ctrl+p";
          name = "plan";
          command = "gh ai plan {{.IssueNumber}}";
        }
        {
          key = "ctrl+w";
          name = "implement";
          command = "gh ai implement {{.IssueNumber}}";
        }
        {
          key = "ctrl+b";
          name = "implement from base";
          command = ''
            set base (git branch --format="%(refname:short)" | fzf --prompt="Base branch: "); or exit 0; test -n "$base"; or exit 0; gh ai implement {{.IssueNumber}} --base "$base"
          '';
        }
      ];
      prs = [
        {
          key = "ctrl+r";
          name = "review";
          command = "gh ai review {{.PrNumber}}";
        }
        {
          key = "ctrl+w";
          name = "implement";
          command = "gh ai implement --pr {{.PrNumber}}";
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
