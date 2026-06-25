# shellcheck shell=bash

usage() {
	printf '%s\n' \
		"gh claude - Agent helpers for GitHub issues and pull requests" \
		"" \
		"USAGE" \
		"  gh claude fix [issue-number | gh-issue-list filters...] [--prompt PROMPT] [--branch BRANCH] [--base BASE]" \
		"  gh claude import <url> [--prompt PROMPT]" \
		"  gh claude review [pr-number | gh-pr-list filters...] [--prompt PROMPT]" \
		"  gh claude triage [issue-number | gh-issue-list filters...] [--prompt PROMPT]" \
		"  gh claude work [pr-number | gh-pr-list filters...] [--prompt PROMPT]" \
		"  gh claude help" \
		"" \
		"COMMANDS" \
		"  fix     Fix an issue by number, or select one with fzf" \
		"  import  Inspect a URL and create a GitHub issue" \
		"  review  Review a PR by number, or select one with fzf" \
		"  triage  Triage an issue by number, or select one with fzf" \
		"  work    Continue work on a PR by number, or select one with fzf" \
		"  help    Show this help" \
		"" \
		"PROMPT VARIABLES" \
		"  import:      {url}" \
		"  review/work: {pr}" \
		"  fix:         {issue}, {branch}, {base}" \
		"  triage:      {issue}" \
		"" \
		"EXAMPLES" \
		"  gh claude fix 123 --prompt 'Fix issue {issue} on {branch} from {base}'" \
		"  gh claude import https://example.com/ticket/123" \
		"  gh claude review 456 --prompt '/review {pr}. Focus on regression risk'" \
		"  gh claude triage --assignee @me" \
		"  gh claude work --author octocat --prompt 'Continue PR {pr}'"
}

select_pr() {
	gh pr list "$@" | fzf | awk '{print $1}'
}

select_issue() {
	gh issue list "$@" | fzf | awk '{print $1}' | sed 's/^#//'
}

is_number() {
	[[ "$1" =~ ^[0-9]+$ ]]
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

	if [ "${#issue_args[@]}" -gt 0 ] && is_number "${issue_args[0]}"; then
		issue="${issue_args[0]}"
		if [ "${#issue_args[@]}" -gt 1 ]; then
			echo "gh claude fix: unexpected filters after direct issue number" >&2
			exit 2
		fi
	else
		issue=$(select_issue "${issue_args[@]}") || exit 0
		[ -n "$issue" ] || exit 0
	fi

	if [ -z "$branch" ]; then
		branch="issue-$issue"
	fi

	if [ -z "$base" ]; then
		base=$(default_branch)
	fi

	if [ -n "$custom_prompt" ]; then
		prompt="$custom_prompt"
	else
		prompt="Fix GitHub issue #{issue}. Start by reading the issue to understand the problem, then implement a fix."
	fi

	prompt=$(render_template "$prompt" issue "$issue" branch "$branch" base "$base")

	printf -v command 'wt switch -c %q -b %q -x cx -- %q' "$branch" "$base" "$prompt"
	open_tmux_window "$command"
}

run_issue_prompt() {
	local command_name="$1"
	local default_prompt="$2"
	shift 2
	local custom_prompt=""
	local issue
	local prompt
	local command
	local -a issue_args=()

	while [ "$#" -gt 0 ]; do
		case "$1" in
		--prompt)
			shift
			if [ "$#" -eq 0 ]; then
				echo "gh claude $command_name: --prompt requires a value" >&2
				exit 2
			fi
			custom_prompt="$1"
			;;
		--prompt=*)
			custom_prompt="${1#--prompt=}"
			;;
		*)
			issue_args+=("$1")
			;;
		esac
		shift
	done

	if [ "${#issue_args[@]}" -gt 0 ] && is_number "${issue_args[0]}"; then
		issue="${issue_args[0]}"
		if [ "${#issue_args[@]}" -gt 1 ]; then
			echo "gh claude $command_name: unexpected filters after direct issue number" >&2
			exit 2
		fi
	else
		issue=$(select_issue "${issue_args[@]}") || exit 0
		[ -n "$issue" ] || exit 0
	fi

	if [ -n "$custom_prompt" ]; then
		prompt="$custom_prompt"
	else
		prompt="$default_prompt"
	fi

	prompt=$(render_template "$prompt" issue "$issue")

	printf -v command 'cx -- %q' "$prompt"
	open_tmux_window "$command"
}

triage() {
	run_issue_prompt "triage" "Triage GitHub issue #{issue}. Gather enough context to make this issue ready for implementation. Read the issue, inspect the relevant code paths, identify missing information, likely root cause or affected components, risks, and a concrete implementation approach.

Do not implement the fix. If the issue is ready, add a GitHub issue comment summarizing:
- Problem understanding
- Relevant files or code paths
- Missing questions, if any
- Proposed implementation approach
- Suggested acceptance criteria or tests

If it is not ready, comment with the specific missing information needed." "$@"
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
	local prompt
	local command
	local -a pr_args=()

	parse_pr_prompt_args custom_prompt pr_args "$@"

	if [ "${#pr_args[@]}" -gt 0 ] && is_number "${pr_args[0]}"; then
		pr="${pr_args[0]}"
		if [ "${#pr_args[@]}" -gt 1 ]; then
			echo "gh claude: unexpected filters after direct PR number" >&2
			exit 2
		fi
	else
		pr=$(select_pr "${pr_args[@]}") || exit 0
		[ -n "$pr" ] || exit 0
	fi

	if [ -n "$custom_prompt" ]; then
		prompt="$custom_prompt"
	else
		prompt="$default_prompt"
	fi

	prompt=$(render_template "$prompt" pr "$pr")

	printf -v command 'wt switch %q -x cx -- %q' "pr:$pr" "$prompt"
	open_tmux_window "$command"
}

review() {
	run_pr_agent "/review {pr}" "$@"
}

work() {
	run_pr_agent "Continue work on PR #{pr}. Start by reading the PR and checking the current branch state before making changes." "$@"
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
triage)
	shift
	triage "$@"
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
