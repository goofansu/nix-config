#!/usr/bin/env fish

function usage
    printf '%s\n' \
        'gh ai - Agent workflow helpers for GitHub issues and pull requests' \
        '' \
        USAGE \
        '  gh ai <command> [flags]' \
        '' \
        COMMANDS \
        '  import <url>' \
        '      Inspect a URL and create a GitHub issue' \
        '  plan [issue-number | gh issue list filters...]' \
        '      Analyze an issue and create or update its implementation plan' \
        '  implement [issue-number | gh issue list filters...]' \
        '      Implement an issue plan by number, or select an issue with fzf' \
        '  implement --pr [pr-number | gh pr list filters...]' \
        '      Continue implementation on a PR by number, or select one with fzf' \
        '  review [pr-number | gh pr list filters...]' \
        '      Review a PR by number, or select one with fzf' \
        '  help' \
        '      Show this help' \
        '' \
        'GLOBAL FLAGS' \
        '  --prompt PROMPT  Custom prompt template for the agent.' \
        '' \
        'COMMAND FLAGS' \
        '  implement:' \
        '    --base BASE      Branch to start issue implementation from. Omit to use the default branch.' \
        '    --branch BRANCH  Branch to create for issue implementation. Defaults to issue-<number>-<title-slug>.' \
        '    --pr            Continue implementation from a pull request instead of an issue.' \
        '' \
        'PROMPT VARIABLES' \
        '  import:        {url}' \
        '  plan:          {issue}' \
        '  implement:     {issue}, {branch}, {base}' \
        '  implement --pr:{pr}' \
        '  review:        {pr}' \
        '' \
        EXAMPLES \
        '  gh ai import https://example.com/ticket/123' \
        "  gh ai plan 123 --prompt 'Plan issue {issue}'" \
        "  gh ai implement 123 --prompt 'Implement issue {issue}'" \
        "  gh ai implement --pr 456 --prompt 'Continue PR {pr}'" \
        "  gh ai review 456 --prompt '/review {pr}. Focus on regression risk'"
end

function select_pr
    gh pr list $argv \
        --json number,title,author,updatedAt \
        --template '{{range .}}{{tablerow (printf "#%v" .number | color "green") .title .author.login (timeago .updatedAt)}}{{end}}{{tablerender}}' \
        | fzf --ansi \
        | awk '{print $1}' \
        | sed 's/^#//'
end

function select_issue
    gh issue list $argv \
        --json number,title,author,updatedAt \
        --template '{{range .}}{{tablerow (printf "#%v" .number | color "green") .title .author.login (timeago .updatedAt)}}{{end}}{{tablerender}}' \
        | fzf --ansi \
        | awk '{print $1}' \
        | sed 's/^#//'
end

function is_number
    test (count $argv) -gt 0; and string match -rq '^[0-9]+$' -- $argv[1]
end

function argv_contains_branch_options
    for arg in $argv
        switch $arg
            case --branch '--branch=*'
                return 0
            case --base '--base=*'
                return 0
        end
    end
    return 1
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

function agent_options
    set -l name $argv[1]

    printf '%s ' --remote-control
    if test -n "$name"
        printf '%s %s ' --name (fish_quote "$name")
    end
end

function run_issue_agent
    set -l command_name $argv[1]
    set -l default_prompt $argv[2]
    set -e argv[1..2]

    set -l custom_prompt ''
    set -l branch ''
    set -l base ''
    set -l issue ''
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
        set issue (select_issue $issue_args)
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
    set -l agent_options (agent_options "$issue_title")

    set command "$command -x cx -- $agent_options"(fish_quote "$prompt")
    open_tmux_window "$command"
end

function run_current_repo_issue_agent
    set -l command_name $argv[1]
    set -l default_prompt $argv[2]
    set -e argv[1..2]

    set -l custom_prompt ''
    set -l issue ''
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
            case --branch '--branch=*'
                echo "gh ai $command_name: --branch is not supported" >&2
                exit 2
            case --base '--base=*'
                echo "gh ai $command_name: --base is not supported" >&2
                exit 2
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
        set issue (select_issue $issue_args)
        or exit 0
        test -n "$issue"; or exit 0
    end

    set -l issue_title (gh issue view $issue --json title -q .title 2>/dev/null)

    set -l prompt
    if test -n "$custom_prompt"
        set prompt $custom_prompt
    else
        set prompt $default_prompt
    end

    set prompt (render_template "$prompt" issue "$issue")
    set -l agent_options (agent_options "$issue_title")
    set -l command "cx $agent_options-- "(fish_quote "$prompt")
    open_tmux_window "$command"
end

function plan
    run_current_repo_issue_agent plan 'Analyze GitHub issue #{issue} and create or update its implementation plan in the issue. Use this structure: ## Summary, ## Root Cause, ## Implementation Plan, ## Risks, ## Acceptance Criteria.' $argv
end

function implement
    set -l pr_mode 0
    set -l remaining_args

    for arg in $argv
        switch $arg
            case --pr
                set pr_mode 1
            case '*'
                set -a remaining_args $arg
        end
    end

    if test $pr_mode -eq 1
        if argv_contains_branch_options $remaining_args
            for arg in $remaining_args
                switch $arg
                    case --branch '--branch=*'
                        echo 'gh ai implement --pr: --branch is not supported' >&2
                        exit 2
                    case --base '--base=*'
                        echo 'gh ai implement --pr: --base is not supported' >&2
                        exit 2
                end
            end
        end

        run_pr_agent 'Continue implementation on PR #{pr}. Start by reading the PR, review feedback, and current branch state. Address requested changes, run relevant tests, and update the existing PR.' $remaining_args
    else
        run_issue_agent implement 'Read the implementation plan in GitHub issue #{issue}, then implement the requested change. If the plan needs correction, update the issue with the improved plan. When you open or update the PR, include a Closes #{issue} line in the PR body for new PRs.' $argv
    end
end

function import_url
    set -l custom_prompt ''
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
    set -l agent_options (agent_options '')
    set -l command "cx $agent_options-- "(fish_quote "$prompt")
    open_tmux_window "$command"
end

function run_pr_agent
    set -l default_prompt $argv[1]
    set -e argv[1]
    set -l custom_prompt ''
    set -l pr ''
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
    set -l agent_options (agent_options "$pr_title")

    set -l command "wt switch "(fish_quote "pr:$pr")" -x cx -- $agent_options"(fish_quote "$prompt")
    open_tmux_window "$command"
end

function review
    run_pr_agent 'Review PR #{pr} for correctness, regressions, maintainability, tests, and edge cases.' $argv
end

switch $argv[1]
    case import
        set -e argv[1]
        import_url $argv
    case plan
        set -e argv[1]
        plan $argv
    case implement
        set -e argv[1]
        implement $argv
    case review
        set -e argv[1]
        review $argv
    case help --help -h
        usage
    case ''
        usage
    case '*'
        echo "gh ai: unknown command '$argv[1]'" >&2
        usage >&2
        exit 2
end
