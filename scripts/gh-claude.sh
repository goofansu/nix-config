# shellcheck shell=bash

usage() {
	printf '%s\n' \
		"gh claude - Agent helpers for GitHub issues and pull requests" \
		"" \
		"USAGE" \
		"  gh claude fix [gh-issue-list filters...] [--prompt PROMPT] [--branch BRANCH] [--base BASE]" \
		"  gh claude review [gh-pr-list filters...] [--prompt PROMPT]" \
		"  gh claude help" \
		"" \
		"COMMANDS" \
		"  fix     Select an issue with fzf and fix it in a new tmux window" \
		"  review  Select a PR with fzf and review it in a new tmux window" \
		"  help    Show this help" \
		"" \
		"PROMPT VARIABLES" \
		"  review: {pr}, {title}, {url}, {branch}" \
		"  fix:    {issue}, {title}, {url}, {branch}, {base}" \
		"" \
		"EXAMPLES" \
		"  gh claude fix --assignee @me --prompt 'Fix {url} on {branch} from {base}'" \
		"  gh claude review --search bug --prompt '/review {pr}. Focus on regression risk in {branch}'"
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
	tmux new-window "$command"
}

review() {
	local custom_prompt=""
	local pr
	local title
	local url
	local branch
	local prompt
	local command
	local -a pr_args=()

	while [ "$#" -gt 0 ]; do
		case "$1" in
		--prompt)
			shift
			if [ "$#" -eq 0 ]; then
				echo "gh claude review: --prompt requires a value" >&2
				exit 2
			fi
			custom_prompt="$1"
			;;
		--prompt=*)
			custom_prompt="${1#--prompt=}"
			;;
		*)
			pr_args+=("$1")
			;;
		esac
		shift
	done

	pr=$(select_pr "${pr_args[@]}") || exit 0
	[ -n "$pr" ] || exit 0

	title=$(gh pr view "$pr" --json title --jq '.title')
	url=$(gh pr view "$pr" --json url --jq '.url')
	branch=$(gh pr view "$pr" --json headRefName --jq '.headRefName')

	if [ -n "$custom_prompt" ]; then
		prompt="$custom_prompt"
	else
		prompt="/review {pr}"
	fi

	prompt=$(render_template "$prompt" pr "$pr" title "$title" url "$url" branch "$branch")

	printf -v command 'wt switch %q -x cx -- %q' "pr:$pr" "$prompt"
	tmux new-window "$command"
}

case "${1:-}" in
fix)
	shift
	fix "$@"
	;;
review)
	shift
	review "$@"
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
