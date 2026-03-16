# Style & Conventions

## Bash Code Style
- Pure Bash; no external dependencies for core runtime
- Shell libraries organized under `bin/lib/` by concern (cli, policy, runtime, support, commands, bootstrap)
- Functions sourced via `bin/lib/bootstrap/source-manifest.sh`

## .sb Policy Authoring
- Standard header: Category/integration/app name, description, `Source:` path
- Stage prefixes: `00`, `10`, `20`, `30`, `40`, `50`, `55`, `60`, `65`
- Files within each stage directory concatenated in lexicographic order
- Dependency metadata: `$$require=path/to/profile.sb$$` (machine-read); `;; Requires:` (human doc only)
- Keep each `.sb` file standalone for its concern
- Prefer narrow path matchers: `literal` > `subpath` when possible
- Include `#safehouse-test-id:*#` markers when tests rely on structure/order

## Testing Conventions
- Test framework: Bats (Bash Automated Testing System)
- Test directories: `tests/policy/`, `tests/surface/`, `tests/e2e/`
- Shared helpers in `tests/test_helper.bash`
- Load helpers from nested dirs: `load ../../test_helper.bash`
- E2E tests load: `../test_helper.bash`, then `tmux_utils.bash`, then `agent_tui_harness.bash`
- Keep tests dist-first: validate packaged entrypoint and generated contracts
- Prefer precise tests for security boundaries and order-sensitive invariants

## General Rules
- Never hand-edit `dist/*` — edit `bin/` and `profiles/`, then regenerate
- Use `rg` for text search, `fd` for file find
- Make least-privilege policy edits; avoid broad `subpath` grants
- Policy assembly order is a first-class behavior constraint
