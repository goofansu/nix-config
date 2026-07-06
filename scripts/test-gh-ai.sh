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
	assert_contains "$output" '  triage [issue-number]'
	assert_contains "$output" '  work [issue-number]'
	assert_contains "$output" 'GLOBAL FLAGS'
	assert_contains "$output" '  --agent COMMAND  Agent executable to run. Defaults to cx.'
	assert_contains "$output" '  --prompt PROMPT  Custom prompt template for the agent.'
	assert_contains "$output" 'COMMAND FLAGS'
	assert_contains "$output" '  work, triage:'
	assert_contains "$output" '    --base BASE      Branch to start the work from. Omit to use the default branch.'
	assert_contains "$output" '    --branch BRANCH  Branch to create for the work. Defaults to issue-<number>-<title-slug>.'
	assert_contains "$output" '  triage: {issue}'
	assert_contains "$output" '  work:   {issue}'
	assert_not_contains "$output" '  work:   {issue}, {branch}, {base}'
	assert_not_contains "$output" "Work issue {issue} on {branch} from {base}"
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
issue\ list\ --author\ @me)
	printf '%s\n' '777	Selected authored issue'
	;;
issue\ list)
	printf '%s\n' '#999	Selected issue'
	;;
issue\ view\ *\ --json\ title\ -q\ .title)
	printf '%s\n' 'Fix Fancy Bug!'
	;;
ready-for-agent)
	printf '%s\n' '999	Selected ready-for-agent issue'
	;;
pr\ list*)
	printf '%s\n' '888	Selected PR'
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

test_work_direct_number_skips_ready_for_agent_picker() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" work 123

	assert_file_missing "$tmp/fzf-called"
	[[ ! -e "$tmp/gh-calls" ]] || ! grep -q '^ready-for-agent$' "$tmp/gh-calls" || fail "did not expect gh ready-for-agent for direct issue number"
	assert_contains "$(cat "$tmp/tmux-calls")" "wt switch -c issue-123-fix-fancy-bug -x cx -- --remote-control --name 'Fix Fancy Bug!'"
	assert_contains "$(cat "$tmp/tmux-calls")" "#123"
	assert_contains "$(cat "$tmp/tmux-calls")" "Closes #123"
}

test_work_without_number_uses_ready_for_agent_picker() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" work

	[[ -e "$tmp/fzf-called" ]] || fail "expected fzf picker"
	grep -q '^ready-for-agent$' "$tmp/gh-calls" || fail "expected gh ready-for-agent"
	assert_contains "$(cat "$tmp/tmux-calls")" "wt switch -c issue-999-fix-fancy-bug -x cx -- --remote-control --name 'Fix Fancy Bug!'"
	assert_contains "$(cat "$tmp/tmux-calls")" "#999"
}

test_review_numeric_filter_still_uses_picker_when_not_first_arg() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" review --search 456

	[[ -e "$tmp/fzf-called" ]] || fail "expected fzf picker for non-first numeric filter value"
	grep -q '^pr list --search 456$' "$tmp/gh-calls" || fail "expected gh pr list to receive filters"
	assert_contains "$(cat "$tmp/tmux-calls")" "wt switch pr:888 -x cx -- --remote-control --name 'Improve PR Flow!'"
}

test_resume_direct_number_skips_pr_picker() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" resume 456 --prompt 'Resume {pr}'

	assert_file_missing "$tmp/fzf-called"
	[[ ! -e "$tmp/gh-calls" ]] || ! grep -q '^pr list' "$tmp/gh-calls" || fail "did not expect gh pr list for direct PR number"
	assert_contains "$(cat "$tmp/tmux-calls")" "wt switch pr:456 -x cx -- --remote-control --name 'Improve PR Flow!'"
	assert_contains "$(cat "$tmp/tmux-calls")" "Resume 456"
}

test_other_agent_gets_no_agent_specific_options() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" work 123 --agent claude --prompt 'Work {issue}'

	assert_fish_parses_tmux_command "$tmp"
	assert_contains "$(cat "$tmp/tmux-calls")" "wt switch -c issue-123-fix-fancy-bug -x claude -- 'Work 123'"
	assert_not_contains "$(cat "$tmp/tmux-calls")" "--name 'Fix Fancy Bug!'"
	assert_not_contains "$(cat "$tmp/tmux-calls")" "--remote-control"
	assert_not_contains "$(cat "$tmp/tmux-calls")" " -b "
	assert_contains "$(cat "$tmp/tmux-calls")" "Work 123"
}

test_triage_pi_agent_passes_issue_title_as_name() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" triage 123 --agent pi

	assert_fish_parses_tmux_command "$tmp"
	assert_contains "$(cat "$tmp/tmux-calls")" "wt switch -c issue-123-fix-fancy-bug -x pi -- --name 'Fix Fancy Bug!'"
	assert_contains "$(cat "$tmp/tmux-calls")" "/triage 123"
}

test_work_base_option_adds_base_flag() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" work 123 --base main --agent claude --prompt 'Work {issue}'

	assert_fish_parses_tmux_command "$tmp"
	assert_contains "$(cat "$tmp/tmux-calls")" "wt switch -c issue-123-fix-fancy-bug -b main -x claude -- 'Work 123'"
	assert_contains "$(cat "$tmp/tmux-calls")" "Work 123"
}

test_work_existing_issue_branch_switches_without_create() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	EXISTING_BRANCH=issue-123-fix-fancy-bug run_gh_ai "$tmp" work 123 --agent claude --prompt 'Work {issue}'

	assert_fish_parses_tmux_command "$tmp"
	assert_contains "$(cat "$tmp/git-calls")" "show-ref --verify --quiet refs/heads/issue-123-fix-fancy-bug"
	assert_contains "$(cat "$tmp/tmux-calls")" "wt switch issue-123-fix-fancy-bug -x claude -- 'Work 123'"
	assert_not_contains "$(cat "$tmp/tmux-calls")" "wt switch -c issue-123-fix-fancy-bug"
	assert_contains "$(cat "$tmp/tmux-calls")" "Work 123"
}

test_triage_direct_number_uses_triage_prompt_and_work_options() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" triage 123 --base main --agent claude

	assert_file_missing "$tmp/fzf-called"
	assert_fish_parses_tmux_command "$tmp"
	assert_contains "$(cat "$tmp/tmux-calls")" "wt switch -c issue-123-fix-fancy-bug -b main -x claude -- '/triage 123'"
	assert_contains "$(cat "$tmp/tmux-calls")" "/triage 123"
}

test_triage_without_number_uses_authored_issue_picker() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" triage

	[[ -e "$tmp/fzf-called" ]] || fail "expected fzf picker"
	grep -q '^issue list --author @me$' "$tmp/gh-calls" || fail "expected gh issue list --author @me"
	assert_contains "$(cat "$tmp/tmux-calls")" "issue-777"
	assert_contains "$(cat "$tmp/tmux-calls")" "/triage 777"
}

test_pi_agent_gets_name_without_remote_control() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" review 456 --agent=pi --prompt 'Review {pr}'

	assert_fish_parses_tmux_command "$tmp"
	assert_contains "$(cat "$tmp/tmux-calls")" "wt switch pr:456 -x pi -- --name 'Improve PR Flow!'"
	assert_not_contains "$(cat "$tmp/tmux-calls")" "--remote-control"
	assert_contains "$(cat "$tmp/tmux-calls")" "Review 456"
}

test_resume_other_agent_gets_no_agent_specific_options() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" resume 456 --agent claude --prompt 'Resume {pr}'

	assert_fish_parses_tmux_command "$tmp"
	assert_contains "$(cat "$tmp/tmux-calls")" "wt switch pr:456 -x claude -- 'Resume 456'"
	assert_not_contains "$(cat "$tmp/tmux-calls")" "--name 'Improve PR Flow!'"
	assert_not_contains "$(cat "$tmp/tmux-calls")" "--remote-control"
	assert_contains "$(cat "$tmp/tmux-calls")" "Resume 456"
}

test_import_default_cx_gets_remote_control() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" import https://example.com/ticket/123 --prompt 'Import {url}'

	assert_fish_parses_tmux_command "$tmp"
	assert_contains "$(cat "$tmp/tmux-calls")" "cx --remote-control -- 'Import https://example.com/ticket/123'"
}

test_import_agent_option_overrides_default_agent() {
	local tmp
	tmp=$(mktemp -d)
	with_stubs "$tmp"

	run_gh_ai "$tmp" import https://example.com/ticket/123 --agent claude --prompt 'Import {url}'

	assert_fish_parses_tmux_command "$tmp"
	assert_contains "$(cat "$tmp/tmux-calls")" "claude --"
	assert_not_contains "$(cat "$tmp/tmux-calls")" "--remote-control"
	assert_contains "$(cat "$tmp/tmux-calls")" "Import https://example.com/ticket/123"
}

for test_name in \
	test_help_uses_gh_style_usage_and_flags \
	test_work_direct_number_skips_ready_for_agent_picker \
	test_work_without_number_uses_ready_for_agent_picker \
	test_other_agent_gets_no_agent_specific_options \
	test_triage_pi_agent_passes_issue_title_as_name \
	test_work_base_option_adds_base_flag \
	test_work_existing_issue_branch_switches_without_create \
	test_triage_direct_number_uses_triage_prompt_and_work_options \
	test_triage_without_number_uses_authored_issue_picker \
	test_pi_agent_gets_name_without_remote_control \
	test_resume_other_agent_gets_no_agent_specific_options \
	test_import_default_cx_gets_remote_control \
	test_import_agent_option_overrides_default_agent \
	test_review_numeric_filter_still_uses_picker_when_not_first_arg \
	test_resume_direct_number_skips_pr_picker; do
	"$test_name"
	echo "ok - $test_name"
done
