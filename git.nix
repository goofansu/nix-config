{ pkgs, pkgs-unstable, ... }:

let
  gh-wt =
    (pkgs.writeShellApplication {
      name = "gh-wt";
      runtimeInputs = with pkgs; [
        fzf
        gawk
        tmux
        pkgs-unstable.gh
      ];
      text = ''
        usage() {
          cat <<'EOF'
        gh wt - Worktrunk helpers for GitHub pull requests

        USAGE
          gh wt review [gh-pr-list filters...] [--prompt PROMPT]
          gh wt help

        COMMANDS
          review  Select a PR with fzf and review it in a new tmux window
          help    Show this help

        EXAMPLES
          gh wt review --search bug --prompt "focus on regression risk"
        EOF
        }

        select_pr() {
          gh pr list "$@" | fzf | awk '{print $1}'
        }

        review() {
          local extra_prompt=""
          local pr
          local prompt
          local command
          local -a pr_args=()

          while [ "$#" -gt 0 ]; do
            case "$1" in
              --prompt)
                shift
                if [ "$#" -eq 0 ]; then
                  echo "gh wt review: --prompt requires a value" >&2
                  exit 2
                fi
                extra_prompt="$1"
                ;;
              --prompt=*)
                extra_prompt="''${1#--prompt=}"
                ;;
              *)
                pr_args+=("$1")
                ;;
            esac
            shift
          done

          pr=$(select_pr "''${pr_args[@]}") || exit 0
          [ -n "$pr" ] || exit 0

          prompt="/review $pr"
          if [ -n "$extra_prompt" ]; then
            prompt="$prompt $extra_prompt"
          fi

          printf -v command 'wt switch %q -x cx -- %q' "pr:$pr" "$prompt"
          tmux new-window "$command"
        }

        case "''${1:-}" in
          review)
            shift
            review "$@"
            ;;
          help|--help|-h)
            usage
            ;;
          "")
            usage
            ;;
          *)
            echo "gh wt: unknown command '$1'" >&2
            usage >&2
            exit 2
            ;;
        esac
      '';
    }).overrideAttrs
      (_: {
        pname = "gh-wt";
      });
in
{
  programs.gh = {
    enable = true;
    package = pkgs-unstable.gh;
    extensions = [ gh-wt ];
    settings = {
      git_protocol = "ssh";
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
      ".pi"
      ".codex"
      ".claude"
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
