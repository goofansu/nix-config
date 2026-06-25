# shellcheck shell=bash

usage() {
	printf '%s\n' \
		"gh claude - Agent helpers for GitHub issues and pull requests" \
		"" \
		"USAGE" \
		"  gh claude fix [gh-issue-list filters...] [--prompt PROMPT] [--branch BRANCH] [--base BASE]" \
		"  gh claude import <url> [--prompt PROMPT]" \
		"  gh claude review [gh-pr-list filters...] [--prompt PROMPT]" \
		"  gh claude work [gh-pr-list filters...] [--prompt PROMPT]" \
		"  gh claude help" \
		"" \
		"COMMANDS" \
		"  fix     Select an issue with fzf and fix it in a new tmux window" \
		"  import  Inspect a URL and create a GitHub issue" \
		"  review  Select a PR with fzf and review it in a new tmux window" \
		"  work    Select a PR with fzf and continue work in a new tmux window" \
		"  help    Show this help" \
		"" \
		"PROMPT VARIABLES" \
		"  import:      {url}" \
		"  review/work: {pr}, {title}, {url}, {branch}" \
		"  fix:         {issue}, {title}, {url}, {branch}, {base}" \
		"" \
		"EXAMPLES" \
		"  gh claude fix --assignee @me --prompt 'Fix {url} on {branch} from {base}'" \
		"  gh claude import https://example.com/ticket/123" \
		"  gh claude review --search bug --prompt '/review {pr}. Focus on regression risk in {branch}'" \
		"  gh claude work --author octocat --prompt 'Continue {url} on {branch}'"
}

select_pr() {
	gh pr list "$@" | fzf | awk '{print $1}'
}

select_issue() {
	gh issue list "$@" | fzf | awk '{print $1}' | sed 's/^#//'
}

slugify() {
	printf '%s' "$1" |
		tr '[:upper:]' '[:lower:]' |
		sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-+/-/g' |
		cut -c 1-50 |
		sed -E 's/-+$//'
}

default_branch() {
	gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'
}

render_template() {
	local text="$1"
	shift

	while [ "$#" -gt 0 ]; do
		local key="$1"
		local value="$2"
		text="${text//\{$key\}/$value}"
		shift 2
	done

	printf '%s' "$text"
}

open_tmux_window() {
	if [ -z "${TMUX:-}" ]; then
		echo "gh claude: must be run inside tmux to open a new window" >&2
		exit 1
	fi

	tmux new-window "$1"
}

fix() {
	local custom_prompt=""
	local branch=""
	local base=""
	local issue
	local title
	local url
	local slug
	local prompt
	local command
	local -a issue_args=()

	while [ "$#" -gt 0 ]; do
		case "$1" in
		--prompt)
			shift
			if [ "$#" -eq 0 ]; then
				echo "gh claude fix: --prompt requires a value" >&2
				exit 2
			fi
			custom_prompt="$1"
			;;
		--prompt=*)
			custom_prompt="${1#--prompt=}"
			;;
		--branch)
			shift
			if [ "$#" -eq 0 ]; then
				echo "gh claude fix: --branch requires a value" >&2
				exit 2
			fi
			branch="$1"
			;;
		--branch=*)
			branch="${1#--branch=}"
			;;
		--base)
			shift
			if [ "$#" -eq 0 ]; then
				echo "gh claude fix: --base requires a value" >&2
				exit 2
			fi
			base="$1"
			;;
		--base=*)
			base="${1#--base=}"
			;;
		*)
			issue_args+=("$1")
			;;
		esac
		shift
	done

	issue=$(select_issue "${issue_args[@]}") || exit 0
	[ -n "$issue" ] || exit 0

	title=$(gh issue view "$issue" --json title --jq '.title')
	url=$(gh issue view "$issue" --json url --jq '.url')

	if [ -z "$branch" ]; then
		slug=$(slugify "$title")
		branch="issue-$issue"
		if [ -n "$slug" ]; then
			branch="$branch-$slug"
		fi
	fi

	if [ -z "$base" ]; then
		base=$(default_branch)
	fi

	if [ -n "$custom_prompt" ]; then
		prompt="$custom_prompt"
	else
		prompt="Fix GitHub issue #{issue}: {title}

{url}

Start by reading the issue to understand the problem, then implement a fix."
	fi

	prompt=$(render_template "$prompt" issue "$issue" title "$title" url "$url" branch "$branch" base "$base")

	printf -v command 'wt switch -c %q -b %q -x cx -- %q' "$branch" "$base" "$prompt"
	open_tmux_window "$command"
}

import_url() {
	local custom_prompt=""
	local url=""
	local prompt
	local command

	while [ "$#" -gt 0 ]; do
		case "$1" in
		--prompt)
			shift
			if [ "$#" -eq 0 ]; then
				echo "gh claude import: --prompt requires a value" >&2
				exit 2
			fi
			custom_prompt="$1"
			;;
		--prompt=*)
			custom_prompt="${1#--prompt=}"
			;;
		*)
			if [ -n "$url" ]; then
				echo "gh claude import: expected exactly one URL" >&2
				exit 2
			fi
			url="$1"
			;;
		esac
		shift
	done

	if [ -z "$url" ]; then
		echo "Usage: gh claude import <url> [--prompt PROMPT]" >&2
		exit 2
	fi

	if [ -n "$custom_prompt" ]; then
		prompt="$custom_prompt"
	else
		prompt="Inspect this URL and create a GitHub issue for the actionable work it describes: {url}. Read the linked content and determine whether it describes a bug, feature request, task, or investigation. Then create a GitHub issue in this repository using gh issue create. The GitHub issue should include a concise title, source URL, summary, expected behavior or desired outcome, relevant context, suggested investigation or implementation notes, and acceptance criteria. If the URL does not contain enough information to create a useful issue, do not create an issue; report what information is missing."
	fi

	prompt=$(render_template "$prompt" url "$url")

	printf -v command 'cx -- %q' "$prompt"
	open_tmux_window "$command"
}

parse_pr_prompt_args() {
	local prompt_var="$1"
	local args_var="$2"
	shift 2
	local parsed_prompt=""
	local -a parsed_args=()

	while [ "$#" -gt 0 ]; do
		case "$1" in
		--prompt)
			shift
			if [ "$#" -eq 0 ]; then
				echo "gh claude: --prompt requires a value" >&2
				exit 2
			fi
			parsed_prompt="$1"
			;;
		--prompt=*)
			parsed_prompt="${1#--prompt=}"
			;;
		*)
			parsed_args+=("$1")
			;;
		esac
		shift
	done

	printf -v "$prompt_var" '%s' "$parsed_prompt"
	eval "$args_var=(\"\${parsed_args[@]}\")"
}

run_pr_agent() {
	local default_prompt="$1"
	shift
	local custom_prompt=""
	local pr
	local title
	local url
	local branch
	local prompt
	local command
	local -a pr_args=()

	parse_pr_prompt_args custom_prompt pr_args "$@"

	pr=$(select_pr "${pr_args[@]}") || exit 0
	[ -n "$pr" ] || exit 0

	title=$(gh pr view "$pr" --json title --jq '.title')
	url=$(gh pr view "$pr" --json url --jq '.url')
	branch=$(gh pr view "$pr" --json headRefName --jq '.headRefName')

	if [ -n "$custom_prompt" ]; then
		prompt="$custom_prompt"
	else
		prompt="$default_prompt"
	fi

	prompt=$(render_template "$prompt" pr "$pr" title "$title" url "$url" branch "$branch")

	printf -v command 'wt switch %q -x cx -- %q' "pr:$pr" "$prompt"
	open_tmux_window "$command"
}

review() {
	run_pr_agent "/review {pr}" "$@"
}

work() {
	run_pr_agent "Continue work on PR #{pr}: {title}

{url}

Start by reading the PR, checking the current branch state, and understanding remaining work before making changes." "$@"
}

case "${1:-}" in
fix)
	shift
	fix "$@"
	;;
import)
	shift
	import_url "$@"
	;;
review)
	shift
	review "$@"
	;;
work)
	shift
	work "$@"
	;;
help | --help | -h)
	usage
	;;
"")
	usage
	;;
*)
	echo "gh claude: unknown command '$1'" >&2
	usage >&2
	exit 2
	;;
esac
