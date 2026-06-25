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

with_stubs() {
	local tmp="$1"
	mkdir -p "$tmp/bin"
	cat >"$tmp/bin/gh" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >>"$GH_CALLS"
case "$1 $2" in
repo\ view)
	printf '%s\n' main
	;;
issue\ list)
	printf '%s\n' '#999	Selected issue'
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
}

run_gh_claude() {
	local tmp="$1"
	shift
	PATH="$tmp/bin:$PATH" \
		GH_CALLS="$tmp/gh-calls" \
		FZF_CALLED="$tmp/fzf-called" \
		TMUX_CALLS="$tmp/tmux-calls" \
		TMUX=1 \
		bash "$repo_root/scripts/gh-claude.sh" "$@"
}

test_fix_direct_number_skips_issue_picker() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_claude "$tmp" fix 123

	assert_file_missing "$tmp/fzf-called"
	[[ ! -e "$tmp/gh-calls" ]] || ! grep -q '^issue list' "$tmp/gh-calls" || fail "did not expect gh issue list for direct issue number"
	assert_contains "$(cat "$tmp/tmux-calls")" "issue-123"
	assert_contains "$(cat "$tmp/tmux-calls")" "#123"
}

test_review_numeric_filter_still_uses_picker_when_not_first_arg() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_claude "$tmp" review --search 456

	[[ -e "$tmp/fzf-called" ]] || fail "expected fzf picker for non-first numeric filter value"
	grep -q '^pr list --search 456$' "$tmp/gh-calls" || fail "expected gh pr list to receive filters"
	assert_contains "$(cat "$tmp/tmux-calls")" "pr:888"
}

test_work_direct_number_skips_pr_picker() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_claude "$tmp" work 456 --prompt 'Continue {pr}'

	assert_file_missing "$tmp/fzf-called"
	[[ ! -e "$tmp/gh-calls" ]] || ! grep -q '^pr list' "$tmp/gh-calls" || fail "did not expect gh pr list for direct PR number"
	assert_contains "$(cat "$tmp/tmux-calls")" "pr:456"
	assert_contains "$(cat "$tmp/tmux-calls")" "Continue\\ 456"
}

test_triage_direct_number_skips_issue_picker() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_claude "$tmp" triage 123 --prompt 'Triage {issue}'

	assert_file_missing "$tmp/fzf-called"
	[[ ! -e "$tmp/gh-calls" ]] || ! grep -q '^issue list' "$tmp/gh-calls" || fail "did not expect gh issue list for direct issue number"
	assert_contains "$(cat "$tmp/tmux-calls")" "Triage\\ 123"
}

for test_name in \
	test_fix_direct_number_skips_issue_picker \
	test_review_numeric_filter_still_uses_picker_when_not_first_arg \
	test_work_direct_number_skips_pr_picker \
	test_triage_direct_number_skips_issue_picker; do
	"$test_name"
	echo "ok - $test_name"
done
