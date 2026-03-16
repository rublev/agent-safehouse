# Suggested Commands

## Development / Running
```bash
# Run safehouse with a command inside the sandbox
./bin/safehouse.sh [--add-dirs-ro=...] [--add-dirs=...] [--enable=...] [--append-profile=...] -- <command> [args...]

# Print assembled policy to stdout (debugging)
./bin/safehouse.sh --stdout

# Explain effective workdir/grants/profile selection
./bin/safehouse.sh --explain --stdout

# Trust and load <workdir>/.safehouse config
./bin/safehouse.sh --trust-workdir-config --stdout
```

## Testing
```bash
# Run default suites (policy + surface) — must be on macOS, outside existing sandbox
./tests/run.sh

# Run tmux-driven E2E startup/prompt-roundtrip suite
./tests/run.sh e2e

# Run all suites
./tests/run.sh all
```

## Build / Distribution
```bash
# Regenerate dist artifacts (required after any .sb or bin/ changes)
./scripts/generate-dist.sh
```

## Docs Site
```bash
pnpm docs:dev       # Local VitePress dev server
pnpm docs:build     # Build static docs
pnpm docs:preview   # Preview built docs
```

## Cloudflare Deploy
```bash
pnpm cf:dev         # Local Wrangler dev
pnpm cf:deploy      # Deploy to staging
pnpm cf:deploy:prod # Deploy to production
```

## System Utilities (Darwin/macOS)
```bash
rg <pattern>        # Text search (ripgrep — preferred over grep)
fd <pattern>        # File find (preferred over find)
git log/diff/status # Version control
```

## Debugging Sandbox Rejections
```bash
# Live denial stream
/usr/bin/log stream --style compact --predicate 'eventMessage CONTAINS "Sandbox:" AND eventMessage CONTAINS "deny("'

# Recent sandboxd history
/usr/bin/log show --last 2m --style compact --predicate 'process == "sandboxd"'
```
