# AGENTS.md

## Linters

When changing files under `scripts/`, run these checks before committing or claiming completion:

```sh
shfmt -d scripts/*.sh
shellcheck scripts/*.sh
/bin/bash -n scripts/*.sh
```

## Tests

When running `scripts/test-gh-ai.sh`, use macOS bash explicitly:

```sh
/bin/bash scripts/test-gh-ai.sh
```

Nix `bash` can hang while creating the heredoc-based command stubs in this test harness.
