{ pkgs, ... }:

let
  tmux-pick-session = pkgs.writeShellApplication {
    name = "tmux-pick-session";
    runtimeInputs = with pkgs; [
      zoxide
      fzf
      tmux
      coreutils
    ];
    text = ''
      dir=$(zoxide query --list | fzf --prompt='New session: ') || exit 0
      session=$(basename "$dir" | tr '.:' '_')
      tmux new-session -d -c "$dir" -s "$session" 2>/dev/null || true
      tmux switch-client -t "$session"
    '';
  };

  tmux-pick-worktree = pkgs.writeShellApplication {
    name = "tmux-pick-worktree";
    runtimeInputs = with pkgs; [
      fzf
      tmux
      jq
    ];
    text = ''
      branch=$(wt list --format json | jq -r '.[] | .branch' | fzf --prompt='New window: ') || exit 0
      tmux new-window "wt switch $branch; exec fish"
    '';
  };

  tmux-pick-pane = pkgs.writeShellApplication {
    name = "tmux-pick-pane";
    runtimeInputs = with pkgs; [
      fzf
      tmux
      coreutils
    ];
    text = ''
      target=$(
        tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} [#{window_name}] #{pane_current_command} #{b:pane_current_path} #{pane_title}' \
        | fzf --reverse \
            --preview 'tmux capture-pane -pt {1} -e 2>/dev/null || echo "no preview"' \
            --preview-window 'right:60%' \
        | cut -d' ' -f1
      ) || exit 0
      tmux switch-client -t "$target"
    '';
  };

  gh-issue-picker = pkgs.writeShellApplication {
    name = "gh-issue-picker";
    runtimeInputs = with pkgs; [
      gh
      fzf
      coreutils
    ];
    text = ''
      selected=$(gh issue list --author "@me" | fzf --prompt='Issue: ') || exit 0
      issue=$(printf '%s\n' "$selected" | cut -f1)
      test -n "$issue" || exit 0
      printf '%s' "$issue" | /usr/bin/pbcopy
    '';
  };

  gh-pr-picker = pkgs.writeShellApplication {
    name = "gh-pr-picker";
    runtimeInputs = with pkgs; [
      gh
      fzf
      coreutils
    ];
    text = ''
      selected=$(gh pr list --author "@me" | fzf --prompt='PR: ') || exit 0
      pr=$(printf '%s\n' "$selected" | cut -f1)
      test -n "$pr" || exit 0
      printf '%s' "$pr" | /usr/bin/pbcopy
    '';
  };
in
{
  # Fish enables this for completions, but Home Manager 26.05 sets programs.man.package to null on Darwin.
  programs.man.generateCaches = false;

  programs.fish = {
    enable = true;
    shellInit = ''
      set -U hydro_multiline true;
      set -x RUBYOPT "-W0";
    '';
    plugins = with pkgs.fishPlugins; [
      {
        name = "hydro";
        src = hydro.src;
      }
      {
        name = "done";
        src = done.src;
      }
    ];
    functions = {
      rm = {
        description = "Ask before removing a file";
        body = "command rm -i $argv";
      };
      e = {
        description = "Edit file using Emacs GUI";
        body = "emacsclient -nc -s gui $argv";
      };
      gv = {
        description = "Select uncommitted Git files with fzf and choose whether to view in vi or open";
        body = ''
          begin
            git diff --name-only
            git diff --cached --name-only
            git ls-files --others --exclude-standard
          end | sort -u | fzf -m \
            --header='Enter: vi | Ctrl-O: open | Esc: quit' \
            --bind='enter:execute(vi {+})' \
            --bind='ctrl-o:execute(open {+})'
        '';
      };
      cx = {
        description = "Claude Code in Tmux";
        body = "printf \"\\033[2J\\033[3J\\033[H\" && claude --dangerously-skip-permissions $argv";
      };
      t = {
        description = "Attach to Tmux, or start a new session if none is running";
        body = "tmux attach; or tmux new -s Work";
      };
      tdl = {
        description = "Tmux Dev Layout: AI left, terminal right";
        body = ''
          if test -z "$argv[1]"
            echo "Usage: tdl <pi|cx|codex|other_ai> [<second_ai>]"
            return 1
          end
          if test -z "$TMUX"
            echo "You must start tmux to use tdl."
            return 1
          end

          set current_dir $PWD
          set ai $argv[1]
          set ai2 $argv[2]
          set terminal_pane $TMUX_PANE

          # Name the current window after the base directory name
          tmux rename-window -t $terminal_pane (basename $current_dir)

          # Create AI pane to the left of the terminal
          set ai_pane (tmux split-window -h -b -p 50 -t $terminal_pane -c $current_dir -P -F '#{pane_id}')

          # If second AI provided, split the AI column vertically
          if test -n "$ai2"
            set ai2_pane (tmux split-window -v -p 50 -t $ai_pane -c $current_dir -P -F '#{pane_id}')
            tmux send-keys -t $ai2_pane "$ai2" Enter
          end

          # Run AI in the left/top-left pane
          tmux send-keys -t $ai_pane "$ai" Enter

          # Focus the primary AI pane
          tmux select-pane -t $ai_pane
        '';
      };
      tdlm = {
        description = "Tmux Dev Layout per subdirectory";
        body = ''
          if test -z "$argv[1]"
            echo "Usage: tdlm <pi|cx|codex|other_ai> [<second_ai>]"
            return 1
          end
          if test -z "$TMUX"
            echo "You must start tmux to use tdlm."
            return 1
          end

          set ai $argv[1]
          set ai2 $argv[2]
          set base_dir $PWD
          set first true

          # Rename session to current directory name
          tmux rename-session (basename $base_dir | tr '.:' '--')

          for dir in $base_dir/*/
            test -d $dir; or continue
            set dirpath (string trim -r -c / $dir)

            if test $first = true
              tmux send-keys -t $TMUX_PANE "cd '$dirpath' && tdl $ai $ai2" Enter
              set first false
            else
              set pane_id (tmux new-window -c $dirpath -P -F '#{pane_id}')
              tmux send-keys -t $pane_id "tdl $ai $ai2" Enter
            end
          end
        '';
      };
      tsl = {
        description = "Tmux Swarm Layout: N panes running the same command";
        body = ''
          if test -z "$argv[1]" -o -z "$argv[2]"
            echo "Usage: tsl <pane_count> <command>"
            return 1
          end
          if test -z "$TMUX"
            echo "You must start tmux to use tsl."
            return 1
          end

          set count $argv[1]
          set cmd $argv[2]
          set current_dir $PWD
          set panes $TMUX_PANE

          tmux rename-window -t $TMUX_PANE (basename $current_dir)

          while test (count $panes) -lt $count
            set split_target $panes[-1]
            set new_pane (tmux split-window -h -t $split_target -c $current_dir -P -F '#{pane_id}')
            set panes $panes $new_pane
            tmux select-layout -t $panes[1] tiled
          end

          for pane in $panes
            tmux send-keys -t $pane "$cmd" Enter
          end

          tmux select-pane -t $panes[1]
        '';
      };
    };
  };

  programs.ghostty = {
    enable = true;
    package = null;
    enableFishIntegration = true;
    settings = {
      theme = "modus-vivendi";
      font-size = 16;
      font-thicken = true;
      font-family = "Aporetic Sans Mono";
      macos-option-as-alt = true;
      cursor-style-blink = false;
      shell-integration-features = "cursor,sudo,title,ssh-env,ssh-terminfo";
      command = "${pkgs.fish}/bin/fish";
      window-inherit-working-directory = false;
      split-inherit-working-directory = true;
      tab-inherit-working-directory = true;
      keybind = [
        "global:cmd+ctrl+backquote=toggle_quick_terminal"
        "ctrl+shift+l=set_font_size:24" # large
      ];
    };
    themes = {
      modus-vivendi = {
        # Theme: modus-vivendi
        # Description: XTerm port of modus-vivendi (Modus themes for GNU Emacs)
        # Author: Protesilaos Stavrou, <https://protesilaos.com>
        background = "#000000";
        foreground = "#ffffff";
        palette = [
          "0=#000000"
          "1=#ff8059"
          "2=#44bc44"
          "3=#d0bc00"
          "4=#2fafff"
          "5=#feacd0"
          "6=#00d3d0"
          "7=#bfbfbf"
          "8=#595959"
          "9=#ef8b50"
          "10=#70b900"
          "11=#c0c530"
          "12=#79a8ff"
          "13=#b6a0ff"
          "14=#6ae4b9"
          "15=#ffffff"
        ];
      };
    };
  };

  programs.tmux = {
    enable = true;
    prefix = "C-Space";
    terminal = "tmux-256color";
    baseIndex = 1;
    historyLimit = 50000;
    mouse = true;
    keyMode = "vi";
    escapeTime = 0;
    aggressiveResize = true;
    focusEvents = true;

    extraConfig = ''
      bind C-Space send-prefix

      # Reload config
      bind C-r source-file ~/.config/tmux/tmux.conf \; display "Configuration reloaded"

      # Vi mode for copy
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-selection-and-cancel

      # Pane controls
      bind h split-window -v -c "#{pane_current_path}"
      bind v split-window -h -c "#{pane_current_path}"
      bind x kill-pane

      bind -n C-M-Left  select-pane -L
      bind -n C-M-Right select-pane -R
      bind -n C-M-Up    select-pane -U
      bind -n C-M-Down  select-pane -D

      bind -n C-M-S-Left  resize-pane -L 5
      bind -n C-M-S-Down  resize-pane -D 5
      bind -n C-M-S-Up    resize-pane -U 5
      bind -n C-M-S-Right resize-pane -R 5

      # Window navigation
      bind r command-prompt -I "#W" "rename-window -- '%%'"
      bind c new-window -c "#{pane_current_path}"
      bind k confirm-before -p "Kill window #W? (y/n)" kill-window

      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9

      bind -n M-S-Left  swap-window -t -1 \; select-window -t -1
      bind -n M-S-Right swap-window -t +1 \; select-window -t +1

      # Session controls
      bind R command-prompt -I "#S" "rename-session -- '%%'"
      bind K confirm-before -p "Kill session #S? (y/n)" kill-session
      bind P switch-client -p
      bind N switch-client -n

      # General
      set -g allow-passthrough on
      set -g extended-keys on
      set -g extended-keys-format csi-u
      set -as terminal-features ",xterm*:extkeys,*:RGB"
      set -g renumber-windows on
      set -g set-clipboard on
      set -g detach-on-destroy off
      setw -g pane-base-index 1

      # Status bar
      set -g status-position top
      set -g status-interval 5
      set -g status-left-length 30
      set -g status-right-length 50
      set -g window-status-separator ""
      setw -g automatic-rename on
      setw -g automatic-rename-format '#{b:pane_current_path}'

      # Theme
      set -g status-style "bg=default,fg=default"
      set -g status-left "#[fg=black,bg=blue,bold] #S #[bg=default] "
      set -g status-right "#[fg=blue]#{?pane_in_mode,COPY ,}#{?client_prefix,PREFIX ,}#{?window_zoomed_flag,ZOOM ,}#[fg=brightblack]#h "
      set -g window-status-format "#[fg=brightblack] #I:#W "
      set -g window-status-current-format "#[fg=blue,bold] #I:#W "
      set -g pane-border-style "fg=brightblack"
      set -g pane-active-border-style "fg=blue"
      set -g message-style "bg=default,fg=blue"
      set -g message-command-style "bg=default,fg=blue"
      set -g mode-style "bg=blue,fg=black"
      setw -g clock-mode-colour blue

      # Popups
      bind s display-popup -w 90% -h 80% -E "${tmux-pick-pane}/bin/tmux-pick-pane"
      bind C-c display-popup -d "#{pane_current_path}" -E "${tmux-pick-worktree}/bin/tmux-pick-worktree"
      bind C display-popup -E "${tmux-pick-session}/bin/tmux-pick-session"
      bind C-i display-popup -d "#{pane_current_path}" -E "${gh-issue-picker}/bin/gh-issue-picker"
      bind C-p display-popup -d "#{pane_current_path}" -E "${gh-pr-picker}/bin/gh-pr-picker"
      bind g display-popup -d "#{pane_current_path}" -w 90% -h 80% -E "lazygit"
      bind C-g display-popup -d "~/.config/worktrunk" -E "vi config.toml"
      bind a display-popup -d "#{pane_current_path}" -E "vi AGENTS.md"
      bind C-a display-popup -d "~/.pi/agent" -E "vi AGENTS.md"

      # Fire and forget commands
      bind b run-shell -b "cd #{q:pane_current_path} && wt browse-local"
      bind C-b run-shell -b "cd #{q:pane_current_path} && wt browse-remote"
    '';
  };
}
