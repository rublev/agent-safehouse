# What to Do When a Task Is Completed

## After Changing `.sb` Profiles or Runtime Logic (`bin/`, `bin/lib/`)
1. Update or add Bats tests in the relevant `tests/` subdirectory
2. Run `./tests/run.sh` (and `./tests/run.sh e2e` if applicable)
3. Run `./scripts/generate-dist.sh` to regenerate `dist/` artifacts
4. Include regenerated `dist/` files in the same commit/PR

## After Changing Tests Only
1. Run `./tests/run.sh` and/or `./tests/run.sh e2e` depending on suite touched

## After Changing Docs Only
1. No dist regeneration needed
2. Optionally run `pnpm docs:build` to verify

## PR Checklist
- Explain what changed and why
- Describe security/least-privilege impact (especially for new allow rules)
- Include test evidence or state why tests were not runnable
- Confirm `dist/` was regenerated and committed (when required)

## If Running Inside a Sandbox
- If tests cannot run because the session is already sandboxed, state that explicitly and continue with static validation
