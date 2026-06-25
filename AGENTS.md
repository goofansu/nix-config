# AGENTS.md

## Linters

When changing files under `scripts/`, run these checks before committing or claiming completion:

```sh
shfmt -d scripts/*.sh
shellcheck scripts/*.sh
bash -n scripts/*.sh
```
