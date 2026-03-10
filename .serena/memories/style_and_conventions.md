# Style and Conventions

## Shell (Bash)
- Bash scripts use `#!/usr/bin/env bash` or `#!/bin/bash`.
- 2-space indentation (`shfmt -i 2 -ci`).
- Linting: `shellcheck --external-sources` on `bin/safehouse.sh` and `scripts/generate-dist.sh`.
- `shfmt` formatting is advisory (CI uses `continue-on-error: true`).
- Use `rg` (ripgrep) for text search, `fd` for file find.

## Sandbox Profile Language (.sb)
- Each `.sb` file is standalone for its concern/capability.
- Standard header: Category / Integration or App name, Description, `Source:` relative path.
- Stage prefixes: `00`, `10`, `20`, `30`, `40`, `50`, `55`, `60`, `65`.
- Files within a stage directory are concatenated in lexicographic order (`find ... | sort`).
- Dependency metadata: `$$require=path/to/profile.sb[,path/to/other.sb]$$` (machine-read).
- Documentation-only: `;; Requires: ...` comments (human-read).
- Test markers: `#safehouse-test-id:*#` for ordering/structure assertions.
- Prefer narrow matchers: `literal` > `subpath` when possible.
- Keep policy changes least-privilege; avoid broad grants.

## Docs (VitePress)
- TypeScript + Vue components in `docs/.vitepress/`.
- Markdown content in `docs/docs/`.
- No special formatting conventions beyond standard Markdown.

## General
- Apache 2.0 license.
- Security-first: narrow rules, document why broader access is needed.
- Avoid policy churn that breaks common workflows without clear benefit.
