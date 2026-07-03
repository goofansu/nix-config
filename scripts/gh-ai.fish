#!/usr/bin/env fish

function usage
    printf '%s\n' \
        'gh ai - Agent helpers for GitHub issues and pull requests' \
        '' \
        USAGE \
        '  gh ai <command> [flags]' \
        '' \
        COMMANDS \
        '  import <url>' \
        '      Inspect a URL and create a GitHub issue' \
        '  review [pr-number | gh-pr-list filters...]' \
        '      Review a PR by number, or select one with fzf' \
        '  resume [pr-number | gh-pr-list filters...]' \
        '      Continue work on a PR by number, or select one with fzf' \
        '  triage [issue-number]' \
        '      Triage an issue by number, or select one of your issues with fzf' \
        '  work [issue-number]' \
        '      Work on an issue by number, or select one with fzf' \
        '  help' \
        '      Show this help' \
        '' \
        'GLOBAL FLAGS' \
        '  --agent COMMAND  Agent executable to run. Defaults to cx.' \
        '  --prompt PROMPT  Custom prompt template for the agent.' \
        '' \
        'COMMAND FLAGS' \
        '  work, triage:' \
        '    --base BASE      Branch to start the work from. Omit to use the default branch.' \
        '    --branch BRANCH  Branch to create for the work. Defaults to issue-<number>-<title-slug>.' \
        '' \
        'PROMPT VARIABLES' \
        '  import: {url}' \
        '  review: {pr}' \
        '  resume: {pr}' \
        '  triage: {issue}' \
        '  work:   {issue}' \
        '' \
        EXAMPLES \
        "  gh ai work 123 --prompt 'Work issue {issue}'" \
        "  gh ai triage 123 --prompt '/triage {issue}'" \
        '  gh ai import https://example.com/ticket/123' \
        "  gh ai review 456 --prompt '/review {pr}. Focus on regression risk'" \
        "  gh ai resume --author octocat --prompt 'Continue PR {pr}'"
end

function select_pr
    gh pr list $argv | fzf | awk '{print $1}'
end

function select_ready_for_agent_issue
    gh ready-for-agent | fzf | awk '{print $1}' | sed 's/^#//'
end

function select_authored_issue
    gh issue list --author '@me' | fzf | awk '{print $1}' | sed 's/^#//'
end

function is_number
    test (count $argv) -gt 0; and string match -rq '^[0-9]+$' -- $argv[1]
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

function local_branch_exists
    git show-ref --verify --quiet refs/heads/$argv[1] 2>/dev/null
end

function run_issue_agent
    set -l command_name $argv[1]
    set -l picker_function $argv[2]
    set -l default_prompt $argv[3]
    set -e argv[1..3]

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
                    echo "gh ai $command_name: --prompt requires a value" >&2
                    exit 2
                end
                set custom_prompt $argv[1]
            case '--prompt=*'
                set custom_prompt (string replace -- '--prompt=' '' $argv[1])
            case --branch
                set -e argv[1]
                if test (count $argv) -eq 0
                    echo "gh ai $command_name: --branch requires a value" >&2
                    exit 2
                end
                set branch $argv[1]
            case '--branch=*'
                set branch (string replace -- '--branch=' '' $argv[1])
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
            echo "gh ai $command_name: unexpected arguments after direct issue number" >&2
            exit 2
        end
    else
        if test (count $issue_args) -gt 0
            echo "gh ai $command_name: expected an issue number or no arguments" >&2
            exit 2
        end
        set issue ($picker_function)
        or exit 0
        test -n "$issue"; or exit 0
    end

    set -l issue_title (gh issue view $issue --json title -q .title 2>/dev/null)

    if test -z "$branch"
        set -l slug (printf '%s\n' "$issue_title" \
            | string lower \
            | string replace -ra '[^a-z0-9]+' '-' \
            | string trim -c '-' \
            | string sub -l 50 \
            | string trim -c '-')
        if test -n "$slug"
            set branch issue-$issue-$slug
        else
            set branch issue-$issue
        end
    end

    set -l prompt
    if test -n "$custom_prompt"
        set prompt $custom_prompt
    else
        set prompt $default_prompt
    end

    set prompt (render_template "$prompt" issue "$issue" branch "$branch" base "$base")
    set -l command
    if local_branch_exists "$branch"
        set command "wt switch "(fish_quote "$branch")
    else
        set command "wt switch -c "(fish_quote "$branch")
        if test -n "$base"
            set command "$command -b "(fish_quote "$base")
        end
    end
    set -l agent_options ''
    switch $agent
        case claude pi
            if test -n "$issue_title"
                set agent_options " --name "(fish_quote "$issue_title")
            end
    end

    set command "$command -x "(fish_quote "$agent")"$agent_options -- "(fish_quote "$prompt")
    open_tmux_window "$command"
end

function work
    run_issue_agent work select_ready_for_agent_issue 'Read the Agent Brief in GitHub issue #{issue}, then implement the requested change. When you open the PR, include a Closes #{issue} line in the PR body.' $argv
end

function triage
    run_issue_agent triage select_authored_issue '/triage {issue}' $argv
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

    set -l pr_title (gh pr view $pr --json title -q .title 2>/dev/null)

    set -l prompt
    if test -n "$custom_prompt"
        set prompt $custom_prompt
    else
        set prompt $default_prompt
    end

    set prompt (render_template "$prompt" pr "$pr")
    set -l agent_options ''
    switch $agent
        case claude pi
            if test -n "$pr_title"
                set agent_options " --name "(fish_quote "$pr_title")
            end
    end

    set -l command "wt switch "(fish_quote "pr:$pr")" -x "(fish_quote "$agent")"$agent_options -- "(fish_quote "$prompt")
    open_tmux_window "$command"
end

function review
    run_pr_agent '/review {pr}' $argv
end

function resume
    run_pr_agent 'Resume work on PR #{pr}. Start by reading the PR and checking the current branch state before making changes.' $argv
end

switch $argv[1]
    case import
        set -e argv[1]
        import_url $argv
    case review
        set -e argv[1]
        review $argv
    case resume
        set -e argv[1]
        resume $argv
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
