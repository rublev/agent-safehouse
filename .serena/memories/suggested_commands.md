# Suggested Commands

## Core Development
```bash
# Run the sandbox wrapper (generate policy only)
./bin/safehouse.sh [--add-dirs-ro=...] [--add-dirs=...] [--enable=...] [--append-profile=...]

# Run a command inside the sandbox
./bin/safehouse.sh [policy opts] -- <command> [args...]

# Print assembled policy to stdout
./bin/safehouse.sh --stdout

# Explain effective workdir/grants/profile selection
./bin/safehouse.sh --explain --stdout

# Trust and load workdir .safehouse config
./bin/safehouse.sh --trust-workdir-config --stdout
```

## Testing
```bash
# Run all policy behavior tests (macOS only, must be outside an existing sandbox)
./tests/run.sh

# E2E tests with tmux simulation
./tests/e2e/run.sh

# Live agent E2E tests (requires API keys)
./tests/e2e/live/run.sh
```

## Distribution / Build
```bash
# Regenerate deterministic dist artifacts (required after profile/runtime changes)
./scripts/generate-dist.sh
```

## Docs Site
```bash
pnpm docs:dev        # Local dev server
pnpm docs:build      # Build static site
pnpm docs:preview    # Preview built site
pnpm cf:dev          # Build + local Wrangler dev
pnpm cf:deploy       # Build + deploy to Cloudflare (staging)
pnpm cf:deploy:prod  # Build + deploy to Cloudflare (production)
```

## Linting
```bash
# Shell lint (matches CI)
shellcheck --external-sources bin/safehouse.sh scripts/generate-dist.sh

# Shell format check
shfmt -d -i 2 -ci bin/safehouse.sh scripts/generate-dist.sh
```

## Debugging Sandbox Rejections
```bash
# Live denial stream
/usr/bin/log stream --style compact --predicate 'eventMessage CONTAINS "Sandbox:" AND eventMessage CONTAINS "deny("'

# Kernel-level sandbox stream
/usr/bin/log stream --style compact --info --debug --predicate '(processID == 0) AND (senderImagePath CONTAINS "/Sandbox")'

# Recent sandboxd history
/usr/bin/log show --last 2m --style compact --predicate 'process == "sandboxd"'
```

## System Utilities (macOS/Darwin)
```bash
rg <pattern> [path]     # Text search (ripgrep)
fd <pattern> [path]     # File find
git                      # Version control
```
