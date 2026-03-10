# Agent Safehouse — Project Overview

## Purpose
macOS sandbox wrapper for LLM coding agents (Claude Code, Cursor, Aider, Gemini, Codex, Goose, Amp, Auggie, Cline, Copilot CLI, Droid, Kilo Code, OpenCode, Pi, etc.) built on `sandbox-exec`. Uses a deny-first model (`(deny default)`) with composable `.sb` policy profiles to restrict file, network, and IPC access.

## Tech Stack
- **Core runtime**: Pure Bash + macOS Sandbox Profile Language (`.sb`). No build step for the sandbox tool itself.
- **Docs site**: VitePress (v2 alpha) with TypeScript/Vue components, deployed via Cloudflare Workers (Wrangler).
- **Package manager**: pnpm 10.x (docs/cloudflare only).
- **CI**: GitHub Actions (macOS runners for tests, Ubuntu for shell lint, Cloudflare deploy for docs).

## Repository Structure
```
bin/safehouse.sh              — Main CLI entry point
bin/lib/cli.sh                — CLI argument parsing
bin/lib/common.sh             — Shared shell helpers
bin/lib/policy.sh             — Policy assembly orchestrator
bin/lib/policy/10-options.sh  — Policy option processing
bin/lib/policy/20-profile-selection.sh — Profile selection logic
bin/lib/policy/30-assembly.sh — Profile concatenation/assembly
bin/lib/policy/40-generate.sh — Final policy generation
profiles/                     — Authored .sb policy modules (source of truth)
  00-base.sb                  — Base deny-all + minimal allows
  10-system-runtime.sb        — macOS system runtime access
  20-network.sb               — Network access rules
  30-toolchains/              — Language runtime profiles (node, python, go, rust, java, bun, deno, php, perl, ruby, apple-toolchain-core, runtime-managers)
  40-shared/                  — Shared agent rules (agent-common.sb)
  50-integrations-core/       — Always-on integrations (git, scm-clis, launch-services, container-runtime-default-deny)
  55-integrations-optional/   — Opt-in integrations (docker, ssh, keychain, clipboard, electron, macos-gui, chromium-headless, chromium-full, spotlight, kubectl, lldb, 1password, cleanshot, process-control, shell-init, cloud-credentials, browser-native-messaging, agent-browser)
  60-agents/                  — Agent-specific profiles (claude-code, cursor-agent, aider, goose, codex, gemini, amp, auggie, cline, copilot-cli, droid, kilo-code, opencode, pi)
  65-apps/                    — App-wrapper profiles (claude-app, vscode-app)
scripts/generate-dist.sh      — Deterministic dist artifact generator
dist/                         — Generated distribution artifacts (NOT source of truth)
  safehouse.sh                — Single-file distributable with embedded policy
  Claude.app.sandboxed.command / Claude.app.sandboxed-offline.command
  profiles/                   — Pre-assembled .sb profiles
tests/
  run.sh                      — Main test runner
  lib/common.sh               — Test helpers (assert_allowed, assert_denied, etc.)
  lib/setup.sh                — Test environment setup
  sections/*.sh               — Section-based behavior tests (10-filesystem, 20-integrations, 30-runtime, 40-tooling, 50-policy-behavior, 60-wrapper-cli, 70-cli-edge-cases)
  e2e/                        — E2E tests (tmux simulation + live agent tests)
    run.sh                    — TUI agent simulation runner
    live/run.sh               — Live agent E2E tests (requires API keys)
    live/adapters/            — Per-agent live test adapters
docs/                         — VitePress documentation site
cloudflare/worker.js          — Cloudflare Worker for docs hosting
.safehouse                    — Workdir sandbox config for this repo
AGENTS.md                     — LLM quick reference (for coding agents)
CONTRIBUTING.md               — Full contribution guide
```

## Policy Assembly Order (Critical)
Later rules win. Fixed concatenation order:
1. `profiles/00-base.sb` → 2. `profiles/10-system-runtime.sb` → 3. `profiles/20-network.sb`
4. `profiles/30-toolchains/*.sb` → 5. `profiles/40-shared/*.sb` → 6. `profiles/50-integrations-core/*.sb`
7. `profiles/55-integrations-optional/*.sb` (via `--enable`) → 8. `profiles/60-agents/*.sb` → 9. `profiles/65-apps/*.sb`
10. CLI path grants: `--add-dirs-ro` then `--add-dirs`
11. Workdir grant (omitted if `--workdir` explicitly empty)
12. `--append-profile` overlays last

## Key Design Decisions
- `dist/` is generated, never hand-edited. Edit `bin/` and `profiles/`, then regenerate.
- `HOME_DIR` placeholder `__SAFEHOUSE_REPLACE_ME_WITH_ABSOLUTE_HOME_DIR__` in `00-base.sb` is replaced at assembly time.
- Ancestor directory `literal` read grants are intentionally emitted for directory traversal compatibility.
- `.sb` matcher semantics: `literal` (exact), `subpath` (recursive), `prefix` (starts-with), `regex`.

## CI Workflows
- `tests-macos.yml` — Policy behavior tests on macOS runners
- `shell-lint.yml` — shellcheck + shfmt on Ubuntu
- `e2e-agent-tui-macos.yml` — TUI agent E2E simulation tests
- `regenerate-dist.yml` — Auto-regenerate dist artifacts on relevant changes
- `deploy-docs-cloudflare.yml` — Deploy docs site to Cloudflare
