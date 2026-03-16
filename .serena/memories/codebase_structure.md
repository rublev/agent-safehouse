# Codebase Structure

```
agent-safehouse/
├── bin/
│   ├── safehouse.sh              # Main entrypoint
│   └── lib/
│       ├── bootstrap/            # constants.sh, source-manifest.sh
│       ├── cli/                  # parse.sh, output.sh
│       ├── commands/             # main.sh, update.sh, execute.sh, policy.sh
│       ├── policy/               # sources.sh, selection.sh, explain.sh, plan.sh, render.sh, metadata.sh, constants.sh, request.sh
│       ├── runtime/              # launch.sh, environment.sh
│       └── support/              # collections.sh, git-discovery.sh, errors.sh, strings.sh, sb.sh, paths.sh, env.sh
├── profiles/                     # Authored .sb policy modules (source of truth)
│   ├── 00-base.sb
│   ├── 10-system-runtime.sb
│   ├── 20-network.sb
│   ├── 30-toolchains/            # node, python, go, rust, java, ruby, bun, deno, php, perl
│   ├── 40-shared/                # agent-common.sb
│   ├── 50-integrations-core/     # git, ssh-agent, worktrees, launch-services, scm-clis, container-runtime
│   ├── 55-integrations-optional/ # docker, electron, clipboard, ssh, cloud-credentials, chromium, etc.
│   ├── 60-agents/                # claude-code, cursor-agent, aider, gemini, codex, copilot-cli, goose, etc.
│   └── 65-apps/                  # vscode-app, claude-app
├── dist/                         # Generated artifacts (not source of truth)
├── tests/
│   ├── run.sh                    # Test runner
│   ├── test_helper.bash          # Shared Bats helpers
│   ├── policy/                   # Policy contract tests (agents, integrations, runtime, workdir)
│   ├── surface/                  # CLI/packaging contract tests
│   └── e2e/                      # tmux-driven TUI startup/prompt tests
├── scripts/
│   ├── generate-dist.sh          # Packaging pipeline
│   └── publish-homebrew-tap.sh   # Homebrew release
├── docs/                         # VitePress documentation site
├── cloudflare/                   # Cloudflare Workers config
├── .github/                      # CI workflows
├── AGENTS.md                     # LLM quick reference (like CLAUDE.md)
├── CONTRIBUTING.md               # Contribution guidelines
├── CHANGELOG.md
├── RELEASE.md
└── package.json                  # pnpm workspace for docs/CF tooling
```
