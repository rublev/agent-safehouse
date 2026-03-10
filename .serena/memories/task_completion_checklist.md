# Task Completion Checklist

## After changing `.sb` profiles or policy assembly/runtime (`bin/safehouse.sh`, `bin/lib/*.sh`)
1. Update or add tests in `tests/sections/*.sh`.
2. Run `./tests/run.sh` (if outside a sandbox; otherwise state it explicitly).
3. Run `./scripts/generate-dist.sh` to regenerate dist artifacts.
4. Include regenerated `dist/` files in the same commit/PR.

## After changing tests only
1. Run `./tests/run.sh`.

## After changing docs only
1. No dist regeneration needed.
2. Optionally run `pnpm docs:build` to verify.

## After changing shell scripts (`bin/`, `scripts/`)
1. Run `shellcheck --external-sources` on changed files.
2. Optionally run `shfmt -d -i 2 -ci` on changed files.

## General PR Checklist
- Explain what changed and why.
- Describe security/least-privilege impact (for new allow rules).
- Include test evidence or state why tests were not runnable.
- Confirm whether `dist/` was regenerated and committed (when required).
