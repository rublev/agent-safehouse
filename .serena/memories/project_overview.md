# Agent Safehouse — Project Overview

## Purpose
macOS sandbox wrapper for CLI AI/coding agents (Claude Code, Cursor, Aider, Gemini, Codex, Copilot, etc.) built on Apple's `sandbox-exec`. Enforces least-privilege sandboxing via layered `.sb` (Sandbox Profile Language) policy modules.

## Tech Stack
- **Core runtime**: Pure Bash (no build step for the sandbox wrapper itself)
- **Policy language**: Apple Sandbox Profile Language (`.sb` files, Scheme-like syntax)
- **Documentation site**: VitePress (Vue-based static site generator)
- **Hosting**: Cloudflare Workers (via Wrangler)
- **Package management**: pnpm 10.x (for docs/Cloudflare tooling only)
- **Test framework**: Bats (Bash Automated Testing System)
- **CI**: GitHub Actions (macOS runners)
- **Distribution**: Homebrew tap + GitHub Releases

## Security Model
- Starts from `(deny default)` — everything denied by default
- Explicit allow rules added via layered `.sb` profiles
- Policy assembly order is deterministic and order-sensitive (later rules win)
- `--append-profile` is the final override layer

## Key Architecture
- `bin/safehouse.sh`: main entrypoint
- `bin/lib/`: modular shell libraries (cli parsing, policy assembly, runtime launch, support utils)
- `profiles/`: authored `.sb` policy modules organized by numeric stage prefix (00–65)
- `dist/`: generated distribution artifacts (not source of truth — regenerated from bin/ + profiles/)
- `tests/`: Bats test suites (policy, surface, e2e)
- `docs/`: VitePress documentation site
- `scripts/`: build/release tooling

## Policy Assembly Order (stage prefixes)
1. `00-base.sb` → 2. `10-system-runtime.sb` → 3. `20-network.sb` → 4. `30-toolchains/*.sb` → 5. `40-shared/*.sb` → 6. `50-integrations-core/*.sb` → 7. `55-integrations-optional/*.sb` → 8. `60-agents/*.sb` → 9. `65-apps/*.sb` → 10. CLI path grants → 11. Workdir grant → 12. `--append-profile` overlays
