#!/usr/bin/env fish

function usage
    printf '%s\n' \
        'gh ai - Agent helpers for GitHub issues and pull requests' \
        '' \
        USAGE \
        '  gh ai <command> [flags]' \
        '' \
        COMMANDS \
        '  fix [issue-number | gh-issue-list filters...]' \
        '      Fix an issue by number, or select one with fzf' \
        '  import <url>' \
        '      Inspect a URL and create a GitHub issue' \
        '  review [pr-number | gh-pr-list filters...]' \
        '      Review a PR by number, or select one with fzf' \
        '  triage [issue-number | gh-issue-list filters...]' \
        '      Triage an issue by number, or select one with fzf' \
        '  work [pr-number | gh-pr-list filters...]' \
        '      Continue work on a PR by number, or select one with fzf' \
        '  help' \
        '      Show this help' \
        '' \
        'GLOBAL FLAGS' \
        '  --agent COMMAND  Agent executable to run. Defaults to cx.' \
        '  --prompt PROMPT  Custom prompt template for the agent.' \
        '' \
        'COMMAND FLAGS' \
        '  fix:' \
        '    --base BASE      Base branch. Omitted by default.' \
        '    --branch BRANCH  Worktree branch to create. Defaults to issue-<number>.' \
        '  triage:' \
        '    --base BRANCH    Base branch. Defaults to current branch.' \
        '' \
        'PROMPT VARIABLES' \
        '  import:      {url}' \
        '  review/work: {pr}' \
        '  fix:         {issue}, {branch}, {base}' \
        '  triage:      {issue}, {base}' \
        '' \
        EXAMPLES \
        "  gh ai fix 123 --prompt 'Fix issue {issue} on {branch} from {base}'" \
        '  gh ai import https://example.com/ticket/123' \
        "  gh ai review 456 --prompt '/review {pr}. Focus on regression risk'" \
        '  gh ai triage --assignee @me' \
        "  gh ai work --author octocat --prompt 'Continue PR {pr}'"
end

function select_pr
    gh pr list $argv | fzf | awk '{print $1}'
end

function select_issue
    gh issue list $argv | fzf | awk '{print $1}' | sed 's/^#//'
end

function is_number
    test (count $argv) -gt 0; and string match -rq '^[0-9]+$' -- $argv[1]
end

function current_branch
    git branch --show-current
end

function render_template
    set -l text $argv[1]
    set -e argv[1]

    while test (count $argv) -gt 0
        set -l key $argv[1]
        set -l value $argv[2]
        set text (string replace -a -- "{$key}" "$value" "$text")
        set -e argv[1..2]
    end

    printf '%s' "$text"
end

function fish_quote
    string escape -- $argv[1]
end

function open_tmux_window
    if not set -q TMUX
        echo 'gh ai: must be run inside tmux to open a new window' >&2
        exit 1
    end

    tmux new-window $argv[1]
end

function fix
    set -l custom_prompt ''
    set -l branch ''
    set -l base ''
    set -l issue ''
    set -l agent cx
    set -l issue_args

    while test (count $argv) -gt 0
        switch $argv[1]
            case --prompt
                set -e argv[1]
                if test (count $argv) -eq 0
                    echo 'gh ai fix: --prompt requires a value' >&2
                    exit 2
                end
                set custom_prompt $argv[1]
            case '--prompt=*'
                set custom_prompt (string replace -- '--prompt=' '' $argv[1])
            case --branch
                set -e argv[1]
                if test (count $argv) -eq 0
                    echo 'gh ai fix: --branch requires a value' >&2
                    exit 2
                end
                set branch $argv[1]
            case '--branch=*'
                set branch (string replace -- '--branch=' '' $argv[1])
            case --base
                set -e argv[1]
                if test (count $argv) -eq 0
                    echo 'gh ai fix: --base requires a value' >&2
                    exit 2
                end
                set base $argv[1]
            case '--base=*'
                set base (string replace -- '--base=' '' $argv[1])
            case --agent
                set -e argv[1]
                if test (count $argv) -eq 0
                    echo 'gh ai fix: --agent requires a value' >&2
                    exit 2
                end
                set agent $argv[1]
            case '--agent=*'
                set agent (string replace -- '--agent=' '' $argv[1])
            case '*'
                set -a issue_args $argv[1]
        end
        set -e argv[1]
    end

    if test (count $issue_args) -gt 0; and is_number $issue_args[1]
        set issue $issue_args[1]
        if test (count $issue_args) -gt 1
            echo 'gh ai fix: unexpected filters after direct issue number' >&2
            exit 2
        end
    else
        set issue (select_issue $issue_args)
        or exit 0
        test -n "$issue"; or exit 0
    end

    test -n "$branch"; or set branch issue-$issue

    set -l prompt
    if test -n "$custom_prompt"
        set prompt $custom_prompt
    else
        set prompt 'Fix GitHub issue #{issue}. Start by reading the issue to understand the problem, then implement a fix.'
    end

    set prompt (render_template "$prompt" issue "$issue" branch "$branch" base "$base")
    set -l command "wt switch -c "(fish_quote "$branch")
    if test -n "$base"
        set command "$command -b "(fish_quote "$base")
    end
    set command "$command -x "(fish_quote "$agent")" -- "(fish_quote "$prompt")
    open_tmux_window "$command"
end

function run_issue_prompt
    set -l command_name $argv[1]
    set -l default_prompt $argv[2]
    set -e argv[1..2]
    set -l custom_prompt ''
    set -l base ''
    set -l issue ''
    set -l agent cx
    set -l issue_args

    while test (count $argv) -gt 0
        switch $argv[1]
            case --prompt
                set -e argv[1]
                if test (count $argv) -eq 0
                    echo "gh ai $command_name: --prompt requires a value" >&2
                    exit 2
                end
                set custom_prompt $argv[1]
            case '--prompt=*'
                set custom_prompt (string replace -- '--prompt=' '' $argv[1])
            case --base
                set -e argv[1]
                if test (count $argv) -eq 0
                    echo "gh ai $command_name: --base requires a value" >&2
                    exit 2
                end
                set base $argv[1]
            case '--base=*'
                set base (string replace -- '--base=' '' $argv[1])
            case --agent
                set -e argv[1]
                if test (count $argv) -eq 0
                    echo "gh ai $command_name: --agent requires a value" >&2
                    exit 2
                end
                set agent $argv[1]
            case '--agent=*'
                set agent (string replace -- '--agent=' '' $argv[1])
            case '*'
                set -a issue_args $argv[1]
        end
        set -e argv[1]
    end

    if test (count $issue_args) -gt 0; and is_number $issue_args[1]
        set issue $issue_args[1]
        if test (count $issue_args) -gt 1
            echo "gh ai $command_name: unexpected filters after direct issue number" >&2
            exit 2
        end
    else
        set issue (select_issue $issue_args)
        or exit 0
        test -n "$issue"; or exit 0
    end

    test -n "$base"; or set base (current_branch)

    set -l prompt
    if test -n "$custom_prompt"
        set prompt $custom_prompt
    else
        set prompt $default_prompt
    end

    set prompt (render_template "$prompt" issue "$issue" base "$base")
    set -l command "wt switch "(fish_quote "$base")" -x "(fish_quote "$agent")" -- "(fish_quote "$prompt")
    open_tmux_window "$command"
end

function triage
    set -l default_prompt 'Triage GitHub issue #{issue} from base branch {base}. Gather enough context to make this issue ready for implementation. Read the issue, inspect the relevant code paths, identify missing information, likely root cause or affected components, risks, and a concrete implementation approach.

Do not implement the fix. If the issue is ready, add a GitHub issue comment summarizing:
- Problem understanding
- Relevant files or code paths
- Missing questions, if any
- Proposed implementation approach
- Suggested acceptance criteria or tests

If it is not ready, comment with the specific missing information needed.'
    run_issue_prompt triage "$default_prompt" $argv
end

function import_url
    set -l custom_prompt ''
    set -l agent cx
    set -l url ''

    while test (count $argv) -gt 0
        switch $argv[1]
            case --prompt
                set -e argv[1]
                if test (count $argv) -eq 0
                    echo 'gh ai import: --prompt requires a value' >&2
                    exit 2
                end
                set custom_prompt $argv[1]
            case '--prompt=*'
                set custom_prompt (string replace -- '--prompt=' '' $argv[1])
            case --agent
                set -e argv[1]
                if test (count $argv) -eq 0
                    echo 'gh ai import: --agent requires a value' >&2
                    exit 2
                end
                set agent $argv[1]
            case '--agent=*'
                set agent (string replace -- '--agent=' '' $argv[1])
            case '*'
                if test -n "$url"
                    echo 'gh ai import: expected exactly one URL' >&2
                    exit 2
                end
                set url $argv[1]
        end
        set -e argv[1]
    end

    if test -z "$url"
        echo 'Usage: gh ai import <url> [--prompt PROMPT]' >&2
        exit 2
    end

    set -l prompt
    if test -n "$custom_prompt"
        set prompt $custom_prompt
    else
        set prompt 'Inspect this URL and create a GitHub issue for the actionable work it describes: {url}. Read the linked content and determine whether it describes a bug, feature request, task, or investigation. Then create a GitHub issue in this repository using gh issue create. The GitHub issue should include a concise title, source URL, summary, expected behavior or desired outcome, relevant context, suggested investigation or implementation notes, and acceptance criteria. If the URL does not contain enough information to create a useful issue, do not create an issue; report what information is missing.'
    end

    set prompt (render_template "$prompt" url "$url")
    set -l command (fish_quote "$agent")" -- "(fish_quote "$prompt")
    open_tmux_window "$command"
end

function run_pr_agent
    set -l default_prompt $argv[1]
    set -e argv[1]
    set -l custom_prompt ''
    set -l pr ''
    set -l agent cx
    set -l pr_args

    while test (count $argv) -gt 0
        switch $argv[1]
            case --prompt
                set -e argv[1]
                if test (count $argv) -eq 0
                    echo 'gh ai: --prompt requires a value' >&2
                    exit 2
                end
                set custom_prompt $argv[1]
            case '--prompt=*'
                set custom_prompt (string replace -- '--prompt=' '' $argv[1])
            case --agent
                set -e argv[1]
                if test (count $argv) -eq 0
                    echo 'gh ai: --agent requires a value' >&2
                    exit 2
                end
                set agent $argv[1]
            case '--agent=*'
                set agent (string replace -- '--agent=' '' $argv[1])
            case '*'
                set -a pr_args $argv[1]
        end
        set -e argv[1]
    end

    if test (count $pr_args) -gt 0; and is_number $pr_args[1]
        set pr $pr_args[1]
        if test (count $pr_args) -gt 1
            echo 'gh ai: unexpected filters after direct PR number' >&2
            exit 2
        end
    else
        set pr (select_pr $pr_args)
        or exit 0
        test -n "$pr"; or exit 0
    end

    set -l prompt
    if test -n "$custom_prompt"
        set prompt $custom_prompt
    else
        set prompt $default_prompt
    end

    set prompt (render_template "$prompt" pr "$pr")
    set -l command "wt switch "(fish_quote "pr:$pr")" -x "(fish_quote "$agent")" -- "(fish_quote "$prompt")
    open_tmux_window "$command"
end

function review
    run_pr_agent '/review {pr}' $argv
end

function work
    run_pr_agent 'Continue work on PR #{pr}. Start by reading the PR and checking the current branch state before making changes.' $argv
end

switch $argv[1]
    case fix
        set -e argv[1]
        fix $argv
    case import
        set -e argv[1]
        import_url $argv
    case review
        set -e argv[1]
        review $argv
    case triage
        set -e argv[1]
        triage $argv
    case work
        set -e argv[1]
        work $argv
    case help --help -h
        usage
    case ''
        usage
    case '*'
        echo "gh ai: unknown command '$argv[1]'" >&2
        usage >&2
        exit 2
end
