# AGENTS.md

## Linters

When changing files under `scripts/`, run these checks before committing or claiming completion:

```sh
shfmt -d scripts/*.sh
shellcheck scripts/*.sh
/bin/bash -n scripts/*.sh
```
