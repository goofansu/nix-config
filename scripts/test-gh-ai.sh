#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

fail() {
	echo "FAIL: $*" >&2
	exit 1
}

assert_contains() {
	local haystack="$1"
	local needle="$2"
	[[ "$haystack" == *"$needle"* ]] || fail "expected output to contain '$needle', got: $haystack"
}

assert_file_missing() {
	local path="$1"
	[[ ! -e "$path" ]] || fail "expected $path to be absent"
}

assert_fish_parses_tmux_command() {
	local tmp="$1"
	fish -n <"$tmp/tmux-calls" || fail "expected fish to parse tmux command"
}

test_help_uses_gh_style_usage_and_flags() {
	local output
	output=$(fish "$repo_root/scripts/gh-ai.fish" help)

	assert_contains "$output" 'USAGE'
	assert_contains "$output" '  gh ai <command> [flags]'
	assert_contains "$output" '  import <url>'
	assert_contains "$output" '  review [pr-number | gh-pr-list filters...]'
	assert_contains "$output" '  resume [pr-number | gh-pr-list filters...]'
	assert_contains "$output" '  work [issue-number]'
	assert_contains "$output" 'GLOBAL FLAGS'
	assert_contains "$output" '  --agent COMMAND  Agent executable to run. Defaults to cx.'
	assert_contains "$output" '  --prompt PROMPT  Custom prompt template for the agent.'
	assert_contains "$output" 'COMMAND FLAGS'
	assert_contains "$output" '  work:'
	assert_contains "$output" '    --base BASE      Branch to start the work from. Defaults to default branch.'
	assert_contains "$output" '    --branch BRANCH  Branch to create for the work. Defaults to issue-<number>.'
}

with_stubs() {
	local tmp="$1"
	mkdir -p "$tmp/bin"
	cat >"$tmp/bin/gh" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >>"$GH_CALLS"
case "${1-} ${2-}" in
repo\ view)
	printf '%s\n' main
	;;
issue\ list)
	printf '%s\n' '#999	Selected issue'
	;;
triaged\ )
	printf '%s\n' '999	Selected triaged issue'
	;;
pr\ list)
	printf '%s\n' '888	Selected PR'
	;;
*)
	printf 'unexpected gh call: %s\n' "$*" >&2
	exit 1
	;;
esac
STUB
	chmod +x "$tmp/bin/gh"

	cat >"$tmp/bin/fzf" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
touch "$FZF_CALLED"
cat
STUB
	chmod +x "$tmp/bin/fzf"

	cat >"$tmp/bin/tmux" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >>"$TMUX_CALLS"
STUB
	chmod +x "$tmp/bin/tmux"

	cat >"$tmp/bin/git" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >>"$GIT_CALLS"
case "$*" in
branch\ --show-current)
	printf '%s\n' feature/current
	;;
*)
	printf 'unexpected git call: %s\n' "$*" >&2
	exit 1
	;;
esac
STUB
	chmod +x "$tmp/bin/git"
}

run_gh_ai() {
	local tmp="$1"
	shift
	PATH="$tmp/bin:$PATH" \
		GH_CALLS="$tmp/gh-calls" \
		GIT_CALLS="$tmp/git-calls" \
		FZF_CALLED="$tmp/fzf-called" \
		TMUX_CALLS="$tmp/tmux-calls" \
		TMUX=1 \
		fish "$repo_root/scripts/gh-ai.fish" "$@"
}

test_work_direct_number_skips_triaged_picker() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" work 123

	assert_file_missing "$tmp/fzf-called"
	[[ ! -e "$tmp/gh-calls" ]] || ! grep -q '^triaged$' "$tmp/gh-calls" || fail "did not expect gh triaged for direct issue number"
	assert_contains "$(cat "$tmp/tmux-calls")" "issue-123"
	assert_contains "$(cat "$tmp/tmux-calls")" "#123"
}

test_work_without_number_uses_triaged_picker() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" work

	[[ -e "$tmp/fzf-called" ]] || fail "expected fzf picker"
	grep -q '^triaged$' "$tmp/gh-calls" || fail "expected gh triaged"
	assert_contains "$(cat "$tmp/tmux-calls")" "issue-999"
	assert_contains "$(cat "$tmp/tmux-calls")" "#999"
}

test_review_numeric_filter_still_uses_picker_when_not_first_arg() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" review --search 456

	[[ -e "$tmp/fzf-called" ]] || fail "expected fzf picker for non-first numeric filter value"
	grep -q '^pr list --search 456$' "$tmp/gh-calls" || fail "expected gh pr list to receive filters"
	assert_contains "$(cat "$tmp/tmux-calls")" "pr:888"
}

test_resume_direct_number_skips_pr_picker() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" resume 456 --prompt 'Resume {pr}'

	assert_file_missing "$tmp/fzf-called"
	[[ ! -e "$tmp/gh-calls" ]] || ! grep -q '^pr list' "$tmp/gh-calls" || fail "did not expect gh pr list for direct PR number"
	assert_contains "$(cat "$tmp/tmux-calls")" "pr:456"
	assert_contains "$(cat "$tmp/tmux-calls")" "Resume 456"
}

test_work_agent_option_overrides_default_agent() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" work 123 --agent claude --prompt 'Work {issue}'

	assert_fish_parses_tmux_command "$tmp"
	assert_contains "$(cat "$tmp/tmux-calls")" "wt switch -c issue-123 -b ^ -x claude --"
	assert_contains "$(cat "$tmp/tmux-calls")" "Work 123"
}

test_review_agent_equals_option_overrides_default_agent() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" review 456 --agent=pi --prompt 'Review {pr}'

	assert_fish_parses_tmux_command "$tmp"
	assert_contains "$(cat "$tmp/tmux-calls")" "wt switch pr:456 -x pi --"
	assert_contains "$(cat "$tmp/tmux-calls")" "Review 456"
}

test_import_agent_option_overrides_default_agent() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" import https://example.com/ticket/123 --agent claude --prompt 'Import {url}'

	assert_fish_parses_tmux_command "$tmp"
	assert_contains "$(cat "$tmp/tmux-calls")" "claude --"
	assert_contains "$(cat "$tmp/tmux-calls")" "Import https://example.com/ticket/123"
}

for test_name in \
	test_help_uses_gh_style_usage_and_flags \
	test_work_direct_number_skips_triaged_picker \
	test_work_without_number_uses_triaged_picker \
	test_work_agent_option_overrides_default_agent \
	test_review_agent_equals_option_overrides_default_agent \
	test_import_agent_option_overrides_default_agent \
	test_review_numeric_filter_still_uses_picker_when_not_first_arg \
	test_resume_direct_number_skips_pr_picker; do
	"$test_name"
	echo "ok - $test_name"
done
