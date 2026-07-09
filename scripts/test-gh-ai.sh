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

assert_not_contains() {
	local haystack="$1"
	local needle="$2"
	[[ "$haystack" != *"$needle"* ]] || fail "expected output not to contain '$needle', got: $haystack"
}

assert_before() {
	local haystack="$1"
	local earlier="$2"
	local later="$3"
	local rest="${haystack#*"$earlier"}"
	[[ "$rest" != "$haystack" ]] || fail "expected output to contain '$earlier', got: $haystack"
	[[ "$rest" == *"$later"* ]] || fail "expected '$earlier' to appear before '$later', got: $haystack"
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
	assert_contains "$output" '  plan [issue-number | gh issue list filters...]'
	assert_contains "$output" '  implement [issue-number | gh issue list filters...]'
	assert_contains "$output" '  implement --pr [pr-number | gh pr list filters...]'
	assert_contains "$output" '  review [pr-number | gh pr list filters...]'
	assert_before "$output" '  import <url>' '  plan [issue-number | gh issue list filters...]'
	assert_before "$output" '  plan [issue-number | gh issue list filters...]' '  implement [issue-number | gh issue list filters...]'
	assert_before "$output" '  implement [issue-number | gh issue list filters...]' '  implement --pr [pr-number | gh pr list filters...]'
	assert_before "$output" '  implement --pr [pr-number | gh pr list filters...]' '  review [pr-number | gh pr list filters...]'
	assert_contains "$output" 'GLOBAL FLAGS'
	assert_contains "$output" '  --prompt PROMPT  Custom prompt template for the agent.'
	assert_contains "$output" 'COMMAND FLAGS'
	assert_contains "$output" '  implement:'
	assert_contains "$output" '    --base BASE      Branch to start issue implementation from. Omit to use the default branch.'
	assert_contains "$output" '    --branch BRANCH  Branch to create for issue implementation. Defaults to issue-<number>-<title-slug>.'
	assert_contains "$output" '    --pr             Continue implementation from a pull request instead of an issue.'
	assert_contains "$output" '  import:        {url}'
	assert_contains "$output" '  plan:          {issue}'
	assert_contains "$output" '  implement:     {issue}, {branch}, {base}'
	assert_contains "$output" '  implement --pr:{pr}'
	assert_contains "$output" '  review:        {pr}'
	assert_not_contains "$output" '  work '
	assert_not_contains "$output" '  triage '
	assert_not_contains "$output" '  resume '
	assert_not_contains "$output" '  open '
}

with_stubs() {
	local tmp="$1"
	mkdir -p "$tmp/bin"
	cat >"$tmp/bin/gh" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >>"$GH_CALLS"
case "$*" in
repo\ view)
	printf '%s\n' main
	;;
issue\ list\ *--author\ @me*)
	printf '%s\n' '777	Selected authored issue'
	;;
issue\ list\ *--label\ ready-for-agent*)
	printf '%s\n' '999	Selected filtered issue'
	;;
issue\ list*)
	printf '%s\n' '#999	Selected issue'
	;;
issue\ view\ *\ --json\ title\ -q\ .title)
	printf '%s\n' 'Fix Fancy Bug!'
	;;
ready-for-agent)
	printf '%s\n' '999	Selected ready-for-agent issue'
	;;
pr\ list*)
	printf '%s\n' '#888	Selected PR'
	;;
pr\ view\ *\ --json\ title\ -q\ .title)
	printf '%s\n' 'Improve PR Flow!'
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
show-ref\ --verify\ --quiet\ refs/heads/*)
	args=$*
	branch=${args#show-ref --verify --quiet refs/heads/}
	[[ "${EXISTING_BRANCH:-}" == "$branch" ]]
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
		EXISTING_BRANCH="${EXISTING_BRANCH:-}" \
		TMUX=1 \
		fish "$repo_root/scripts/gh-ai.fish" "$@"
}

test_plan_direct_number_skips_issue_picker_and_does_not_switch() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" plan 123 --prompt 'Plan {issue}'

	assert_file_missing "$tmp/fzf-called"
	[[ ! -e "$tmp/gh-calls" ]] || ! grep -q '^issue list' "$tmp/gh-calls" || fail "did not expect gh issue list for direct issue number"
	assert_fish_parses_tmux_command "$tmp"
	assert_not_contains "$(cat "$tmp/tmux-calls")" 'wt switch'
	assert_contains "$(cat "$tmp/tmux-calls")" "cx --remote-control --name 'Fix Fancy Bug!' -- 'Plan 123'"
}

test_plan_without_number_uses_issue_picker_without_switching() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" plan

	[[ -e "$tmp/fzf-called" ]] || fail "expected fzf picker"
	assert_contains "$(cat "$tmp/gh-calls")" "issue list --json number,title,author,updatedAt --template"
	assert_not_contains "$(cat "$tmp/tmux-calls")" 'wt switch'
	assert_contains "$(cat "$tmp/tmux-calls")" "cx --remote-control --name 'Fix Fancy Bug!'"
	assert_contains "$(cat "$tmp/tmux-calls")" '#999'
}

test_plan_rejects_branch_options() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	if run_gh_ai "$tmp" plan 123 --branch issue-123 2>"$tmp/stderr"; then
		fail 'expected plan --branch to fail'
	fi

	assert_contains "$(cat "$tmp/stderr")" 'gh ai plan: --branch is not supported'
	assert_file_missing "$tmp/tmux-calls"
}

test_plan_rejects_base_and_equals_branch_options() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	if run_gh_ai "$tmp" plan 123 --base main 2>"$tmp/stderr-base"; then
		fail 'expected plan --base to fail'
	fi
	if run_gh_ai "$tmp" plan 123 --branch=issue-123 2>"$tmp/stderr-branch"; then
		fail 'expected plan --branch= to fail'
	fi

	assert_contains "$(cat "$tmp/stderr-base")" 'gh ai plan: --base is not supported'
	assert_contains "$(cat "$tmp/stderr-branch")" 'gh ai plan: --branch is not supported'
	assert_file_missing "$tmp/tmux-calls"
}

test_plan_passes_issue_title_as_name_with_remote_control() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" plan 123

	assert_fish_parses_tmux_command "$tmp"
	assert_not_contains "$(cat "$tmp/tmux-calls")" 'wt switch'
	assert_contains "$(cat "$tmp/tmux-calls")" "cx --remote-control --name 'Fix Fancy Bug!'"
	assert_contains "$(cat "$tmp/tmux-calls")" '#123'
	assert_contains "$(cat "$tmp/tmux-calls")" 'Implementation Plan'
}

test_plan_issue_filter_uses_issue_picker_with_filters() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" plan --author @me

	[[ -e "$tmp/fzf-called" ]] || fail "expected fzf picker"
	assert_contains "$(cat "$tmp/gh-calls")" "issue list --author @me --json number,title,author,updatedAt --template"
	assert_not_contains "$(cat "$tmp/tmux-calls")" 'wt switch'
	assert_contains "$(cat "$tmp/tmux-calls")" '#777'
}

test_implement_issue_direct_number_skips_issue_picker() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" implement 123

	assert_file_missing "$tmp/fzf-called"
	[[ ! -e "$tmp/gh-calls" ]] || ! grep -q '^issue list' "$tmp/gh-calls" || fail "did not expect gh issue list for direct issue number"
	assert_contains "$(cat "$tmp/tmux-calls")" "wt switch -c issue-123-fix-fancy-bug -x cx -- --remote-control --name 'Fix Fancy Bug!'"
	assert_contains "$(cat "$tmp/tmux-calls")" '#123'
	assert_contains "$(cat "$tmp/tmux-calls")" 'implementation plan'
	assert_contains "$(cat "$tmp/tmux-calls")" 'Closes #123'
}

test_implement_issue_without_number_uses_issue_picker() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" implement

	[[ -e "$tmp/fzf-called" ]] || fail "expected fzf picker"
	assert_contains "$(cat "$tmp/gh-calls")" "issue list --json number,title,author,updatedAt --template"
	assert_contains "$(cat "$tmp/tmux-calls")" "wt switch -c issue-999-fix-fancy-bug -x cx -- --remote-control --name 'Fix Fancy Bug!'"
	assert_contains "$(cat "$tmp/tmux-calls")" '#999'
}

test_implement_issue_base_option_adds_base_flag() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" implement 123 --base main --prompt 'Implement {issue}'

	assert_fish_parses_tmux_command "$tmp"
	assert_contains "$(cat "$tmp/tmux-calls")" "wt switch -c issue-123-fix-fancy-bug -b main -x cx -- --remote-control --name 'Fix Fancy Bug!'"
	assert_contains "$(cat "$tmp/tmux-calls")" 'Implement 123'
}

test_implement_issue_existing_branch_switches_without_create() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	EXISTING_BRANCH=issue-123-fix-fancy-bug run_gh_ai "$tmp" implement 123 --prompt 'Implement {issue}'

	assert_fish_parses_tmux_command "$tmp"
	assert_contains "$(cat "$tmp/git-calls")" 'show-ref --verify --quiet refs/heads/issue-123-fix-fancy-bug'
	assert_contains "$(cat "$tmp/tmux-calls")" "wt switch issue-123-fix-fancy-bug -x cx -- --remote-control --name 'Fix Fancy Bug!'"
	assert_not_contains "$(cat "$tmp/tmux-calls")" 'wt switch -c issue-123-fix-fancy-bug'
	assert_contains "$(cat "$tmp/tmux-calls")" 'Implement 123'
}

test_implement_issue_filter_uses_issue_picker_with_filters() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" implement --label ready-for-agent

	[[ -e "$tmp/fzf-called" ]] || fail "expected fzf picker"
	assert_contains "$(cat "$tmp/gh-calls")" "issue list --label ready-for-agent --json number,title,author,updatedAt --template"
	assert_contains "$(cat "$tmp/tmux-calls")" 'issue-999'
	assert_contains "$(cat "$tmp/tmux-calls")" '#999'
}

test_review_numeric_filter_still_uses_picker_when_not_first_arg() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" review --search 456

	[[ -e "$tmp/fzf-called" ]] || fail "expected fzf picker for non-first numeric filter value"
	assert_contains "$(cat "$tmp/gh-calls")" "pr list --search 456 --json number,title,author,updatedAt --template"
	assert_contains "$(cat "$tmp/tmux-calls")" "wt switch pr:888 -x cx -- --remote-control --name 'Improve PR Flow!'"
}

test_review_passes_pr_title_as_name_with_remote_control() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" review 456 --prompt 'Review {pr}'

	assert_fish_parses_tmux_command "$tmp"
	assert_contains "$(cat "$tmp/tmux-calls")" "wt switch pr:456 -x cx -- --remote-control --name 'Improve PR Flow!'"
	assert_contains "$(cat "$tmp/tmux-calls")" 'Review 456'
}

test_implement_pr_direct_number_skips_pr_picker() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" implement --pr 456 --prompt 'Continue {pr}'

	assert_file_missing "$tmp/fzf-called"
	[[ ! -e "$tmp/gh-calls" ]] || ! grep -q '^pr list' "$tmp/gh-calls" || fail "did not expect gh pr list for direct PR number"
	assert_contains "$(cat "$tmp/tmux-calls")" "wt switch pr:456 -x cx -- --remote-control --name 'Improve PR Flow!'"
	assert_contains "$(cat "$tmp/tmux-calls")" 'Continue 456'
}

test_implement_pr_flag_after_number_skips_pr_picker() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" implement 456 --pr --prompt 'Continue {pr}'

	assert_file_missing "$tmp/fzf-called"
	[[ ! -e "$tmp/gh-calls" ]] || ! grep -q '^pr list' "$tmp/gh-calls" || fail "did not expect gh pr list for direct PR number"
	assert_contains "$(cat "$tmp/tmux-calls")" 'wt switch pr:456 -x cx -- --remote-control --name'
	assert_contains "$(cat "$tmp/tmux-calls")" 'Continue 456'
}

test_implement_pr_without_number_uses_pr_picker() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" implement --pr

	[[ -e "$tmp/fzf-called" ]] || fail "expected fzf picker"
	assert_contains "$(cat "$tmp/gh-calls")" "pr list --json number,title,author,updatedAt --template"
	assert_contains "$(cat "$tmp/tmux-calls")" "wt switch pr:888 -x cx -- --remote-control --name 'Improve PR Flow!'"
	assert_contains "$(cat "$tmp/tmux-calls")" '#888'
}

test_implement_pr_filter_uses_pr_picker_with_flag_at_end() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" implement --author @me --pr

	[[ -e "$tmp/fzf-called" ]] || fail "expected fzf picker"
	assert_contains "$(cat "$tmp/gh-calls")" "pr list --author @me --json number,title,author,updatedAt --template"
	assert_contains "$(cat "$tmp/tmux-calls")" 'wt switch pr:888'
}

test_implement_pr_filter_uses_pr_picker_with_flag_first() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" implement --pr --author @me

	[[ -e "$tmp/fzf-called" ]] || fail "expected fzf picker"
	assert_contains "$(cat "$tmp/gh-calls")" "pr list --author @me --json number,title,author,updatedAt --template"
	assert_contains "$(cat "$tmp/tmux-calls")" 'wt switch pr:888'
}

test_implement_pr_rejects_branch_options() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	if run_gh_ai "$tmp" implement --pr 456 --base main 2>"$tmp/stderr-base"; then
		fail 'expected implement --pr --base to fail'
	fi
	if run_gh_ai "$tmp" implement --pr 456 --branch=issue-456 2>"$tmp/stderr-branch"; then
		fail 'expected implement --pr --branch= to fail'
	fi
	if run_gh_ai "$tmp" implement --pr 456 --base=main 2>"$tmp/stderr-base-equals"; then
		fail 'expected implement --pr --base= to fail'
	fi

	assert_contains "$(cat "$tmp/stderr-base")" 'gh ai implement --pr: --base is not supported'
	assert_contains "$(cat "$tmp/stderr-branch")" 'gh ai implement --pr: --branch is not supported'
	assert_contains "$(cat "$tmp/stderr-base-equals")" 'gh ai implement --pr: --base is not supported'
	assert_file_missing "$tmp/tmux-calls"
}

test_old_commands_are_unknown() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	for command in work triage resume open; do
		if run_gh_ai "$tmp" "$command" 123 >"$tmp/stdout-$command" 2>"$tmp/stderr-$command"; then
			fail "expected old command $command to fail"
		fi
		assert_contains "$(cat "$tmp/stderr-$command")" "gh ai: unknown command '$command'"
	done
}

test_import_default_cx_gets_remote_control() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" import https://example.com/ticket/123 --prompt 'Import {url}'

	assert_fish_parses_tmux_command "$tmp"
	assert_contains "$(cat "$tmp/tmux-calls")" "cx --remote-control -- 'Import https://example.com/ticket/123'"
}

for test_name in \
	test_help_uses_gh_style_usage_and_flags \
	test_plan_direct_number_skips_issue_picker_and_does_not_switch \
	test_plan_without_number_uses_issue_picker_without_switching \
	test_plan_rejects_branch_options \
	test_plan_rejects_base_and_equals_branch_options \
	test_plan_passes_issue_title_as_name_with_remote_control \
	test_plan_issue_filter_uses_issue_picker_with_filters \
	test_implement_issue_direct_number_skips_issue_picker \
	test_implement_issue_without_number_uses_issue_picker \
	test_implement_issue_base_option_adds_base_flag \
	test_implement_issue_existing_branch_switches_without_create \
	test_implement_issue_filter_uses_issue_picker_with_filters \
	test_review_passes_pr_title_as_name_with_remote_control \
	test_review_numeric_filter_still_uses_picker_when_not_first_arg \
	test_implement_pr_direct_number_skips_pr_picker \
	test_implement_pr_flag_after_number_skips_pr_picker \
	test_implement_pr_without_number_uses_pr_picker \
	test_implement_pr_filter_uses_pr_picker_with_flag_at_end \
	test_implement_pr_filter_uses_pr_picker_with_flag_first \
	test_implement_pr_rejects_branch_options \
	test_old_commands_are_unknown \
	test_import_default_cx_gets_remote_control; do
	"$test_name"
	echo "ok - $test_name"
done
