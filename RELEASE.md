# Releasing Agent Safehouse

The canonical local release workflow lives in the repo-local skill at
[`./.agents/skills/release/SKILL.md`](./.agents/skills/release/SKILL.md).

Use a local agent with that skill. The skill now owns the full process:

- inspect commits and diffs since the last published stable release
- choose the next SemVer version
- draft the new `CHANGELOG.md` release section
- present a dry-run overview and wait for explicit confirmation before making changes
- after confirmation, update `CHANGELOG.md`, regenerate `dist/`, run the verification gate, publish the GitHub release, and publish the stable Homebrew tap

Release rules:

- Stable releases use `vX.Y.Z`
- Prereleases use `vX.Y.Z-rc.N`, `vX.Y.Z-beta.N`, or another valid SemVer prerelease suffix
- `dist/safehouse.sh` is the only custom GitHub release asset
- Stable releases also update the Homebrew tap at [eugene1g/homebrew-safehouse](https://github.com/eugene1g/homebrew-safehouse)
- Prereleases are published as GitHub prereleases and do not update the Homebrew tap

## Prompt

Give your local agent this prompt:

```text
Use the repo-local `release` skill to prepare the next release.
```

The skill itself owns the dry run, confirmation gate, changelog draft, version
selection, release publishing, and stable Homebrew tap update.

Install a tagged release asset with:

```bash
RELEASE=vX.Y.Z
curl -fsSL "https://github.com/eugene1g/agent-safehouse/releases/download/${RELEASE}/safehouse.sh" \
  -o ~/.local/bin/safehouse
chmod +x ~/.local/bin/safehouse
```
