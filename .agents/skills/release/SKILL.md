---
name: release
description: Run the local Agent Safehouse release flow: inspect commits since the last published release, propose the next SemVer version and changelog, present a dry-run for confirmation, then update changelog, publish the GitHub release, and publish the stable Homebrew tap when confirmed.
---

# Release

Use this skill when the user wants changelog text, release notes, or a `CHANGELOG.md` update for Agent Safehouse.
This skill is also the canonical local release workflow for Agent Safehouse.

Historical changelog sections are append-only by default.
Do not rewrite, normalize, or reformat older release entries to match a newer structure unless the user explicitly asks for a changelog migration or cleanup pass.

This skill is responsible for proposing the next release version from the last published release.
Write that version into the new `CHANGELOG.md` heading unless the user explicitly gives a different target version.
Default to a stable release. Only choose a prerelease version such as `-rc.N` or `-beta.N` when the user explicitly asks for a prerelease.

## Workflow

1. Resolve the baseline release.
   If the user gives a starting version, use it.
   Otherwise:
   - Prefer the latest published stable GitHub release tag from `gh release list --exclude-drafts --exclude-pre-releases`.
   - Ignore draft releases.
   - Ignore prereleases such as `-rc`, `-beta`, and other hyphenated SemVer suffixes unless the user explicitly asks to prepare a prerelease.
   - If GitHub release metadata is unavailable, fall back to the latest stable SemVer git tag.

2. Decide the next SemVer version from the release range.
   Start from the resolved baseline release and choose:
   - `major` for breaking changes, incompatible CLI behavior, removed capabilities, changed defaults that are likely to break existing setups, or sandbox/policy tightening that requires user action to restore a previously supported workflow.
   - `minor` for backward-compatible new features, new integrations, new profiles, new user-visible capabilities, or meaningful expansions of supported workflows.
   - `patch` for bug fixes, non-breaking sandbox/profile corrections, docs, tests, internal cleanup, and other maintenance-only changes.
   - If the range mixes features and fixes but nothing breaking, choose `minor`.
   - If the range is ambiguous and there is no clear breaking change or new feature, choose `patch`.
   - If you choose `major`, explicitly state why in the drafted release notes.
   - If the user explicitly asks for a prerelease, first choose the target stable version using the rules above, then append the requested prerelease suffix such as `-rc.1` or `-beta.1`.
   - If the user explicitly asks for another prerelease in the same series, increment that series from the latest matching non-draft prerelease tag or release, for example `1.4.0-rc.1` to `1.4.0-rc.2`.

3. Collect git context directly.
   Default the target ref to `HEAD` unless the user specifies another tag or commit.
   Treat `dist/` as generated output, not release-note source of truth.
   Do not load `dist/` diffs or `dist/` files into context while evaluating customer-visible changes, choosing the version bump, or drafting changelog bullets.
   Evaluate the original source changes in the rest of the repo instead, especially `bin/`, `bin/lib/`, `profiles/`, `scripts/`, `tests/`, and docs.
   Start with:
   - `git log --reverse --no-merges <from-ref>..<to-ref> --format='%h %s'`
   - `git log --reverse --merges <from-ref>..<to-ref> --format='%h %s'`
   - `git diff --stat <from-ref>..<to-ref> -- . ':(exclude)dist/**'`
   - `git diff --dirstat=files,0 <from-ref>..<to-ref> -- . ':(exclude)dist/**'`
   - `git diff --name-only <from-ref>..<to-ref> -- 'profiles/**/*.sb' 'profiles/*.sb'`
   - `git diff --name-only <from-ref>..<to-ref> -- . ':(exclude)dist/**'`
   Only look at `dist/` after confirmation, during the regeneration and verification stage.

4. Review anything ambiguous before writing notes.
   Use `git show --stat <sha>` or `git diff <from-ref>..<to-ref> -- <path>` for commits that are not obvious from the subject line.
   When a commit touches both source files and `dist/`, review only the source files and do not open the generated `dist/` portion.
   For any changed sandbox profile, inspect the actual diff before summarizing it.

5. Draft changelog bullets in this order:
   - `### Upgrade Notes`
   - `### Features`
   - `### Bug Fixes`
   - `### Chores`
   - `### Misc`
   - `### Changed Sandboxing Profiles`

6. Keep the changelog high signal.
   - Use `Upgrade Notes` only for changes that require user action, verification, migration, reinstall steps, or awareness of a compatibility/default change.
   - If a change is breaking or likely to surprise existing users, put the actionable guidance in `Upgrade Notes`.
   - Start an upgrade note with `Breaking:` when the change is intentionally incompatible.
   - Do not repeat the same customer-facing point across multiple sections unless the extra context is genuinely useful.
   - Prefer user-visible behavior, compatibility, and install/release changes.
   - Collapse related commits into one bullet when they are part of the same outcome.
   - Omit `dist/`-only changes and pure `chore: regenerate dist artifacts` commits from changelog analysis.
   - Do not treat generated `dist/` diffs as independent features, fixes, chores, or reasons to bump the version.
   - Put docs-only, tests-only, and internal cleanup into `Chores` only if they are worth calling out.
   - Use `Misc` only for noteworthy items that do not fit `Features`, `Bug Fixes`, or `Chores`.
   - If any `.sb` files changed under `profiles/`, always include `### Changed Sandboxing Profiles`.

7. Dry run and confirmation gate.
   Before changing any files or publishing anything, prepare a release dry run for the user.
   The dry run must include:
   - the baseline release you resolved
   - the proposed next version
   - whether it is a stable release or a prerelease
   - the reason for the patch/minor/major bump
   - the full proposed new release section for `CHANGELOG.md`
   - whether the Homebrew tap will be updated
   - the exact next actions you intend to take after confirmation
   The exact next actions should be listed in order:
   - update `CHANGELOG.md`
   - regenerate `dist/`
   - run the verification gate
   - commit and push the release-ready state
   - tag and push the release tag
   - publish or update the GitHub release
   - publish the Homebrew tap for stable releases only
   Stop after presenting this overview and wait for explicit user confirmation.
   Do not update `CHANGELOG.md`, regenerate `dist/`, run the verification gate, create commits, create tags, push commits, push tags, create GitHub releases, edit GitHub releases, or publish the Homebrew tap until the user explicitly confirms.

8. After confirmation, update `CHANGELOG.md`.
   For a tagged release, create or update a heading shaped like `## [1.2.3] - YYYY-MM-DD`, using the version you selected in step 2, then move or rewrite the relevant unreleased bullets underneath it.
   Treat `## [Unreleased]` as the working buffer for the next release.
   Move only the notes that are shipping in the release you are drafting.
   Leave unrelated future work under `## [Unreleased]`.
   Insert the new release section immediately below `## [Unreleased]` so the newest release stays at the top of the file.
   Do not add explanatory prose ahead of `## [Unreleased]` or ahead of the latest release section.
   If format notes are needed, keep them at the end of the file.
   After moving shipped notes out of `## [Unreleased]`, keep that section sparse:
   - Always keep `### Upgrade Notes` with either real bullets or `- No special notes.`
   - Always keep `### Changed Sandboxing Profiles` with either real bullets or `- No profiles changed.`
   - Keep `### Features`, `### Bug Fixes`, `### Chores`, and `### Misc` only when they contain actual unreleased notes.
   - Remove empty `Features`, `Bug Fixes`, `Chores`, and `Misc` subsections instead of leaving placeholder text.
   Apply the current structure only to the section you are drafting.
   Leave older release sections in their existing format unless the user explicitly asks to revise historical entries.

9. After confirmation, regenerate `dist/` and run the verification gate.
   Always regenerate `dist/` before publishing:
   - `./scripts/generate-dist.sh`
   Then run the verification gate from an unsandboxed macOS shell:
   - `./tests/run.sh`
   - `test -x dist/safehouse.sh`
   - `bash -n dist/safehouse.sh`
   - `./dist/safehouse.sh --explain --stdout >/dev/null`
   If the verification gate cannot run because the current shell is already sandboxed or the environment is otherwise unsuitable, stop before publishing and tell the user.

10. After confirmation, publish the GitHub release locally with `gh`.
   Derive the final tag as `v<version>`.
   Commit and push the release-ready state.
   Create and push the tag.
   Extract the new release notes from the new `CHANGELOG.md` section and validate that the extracted notes are not empty.
   Attach only `dist/safehouse.sh` as the custom asset and use the drafted changelog text for the release body.
   Use `gh release create --verify-tag` so publishing fails if the remote tag is missing.
   If updating an existing draft release, publish it with `gh release edit --draft=false`.
   If the selected version contains a SemVer prerelease suffix, publish it with `gh release create --prerelease` or `gh release edit --prerelease` so GitHub marks it as a prerelease.

11. After confirmation, publish the Homebrew tap for stable releases.
   For every stable release, update the Homebrew tap repository at `https://github.com/eugene1g/homebrew-safehouse`.
   Use `./scripts/publish-homebrew-tap.sh "v<version>" --push`.
   Skip this step for prereleases such as `-rc.N` and `-beta.N`.

## Changed Sandboxing Profiles

When any sandbox profiles changed in the release range, add a separate section:

```md
### Changed Sandboxing Profiles

- [`profiles/55-integrations-optional/keychain.sb`](https://github.com/eugene1g/agent-safehouse/blob/<permalink-ref>/profiles/55-integrations-optional/keychain.sb): Tightened keychain access so agents only get the lookups required for login flows.
```

Rules:

- Include every changed `.sb` file under `profiles/`.
- For each bullet, say what changed and why in one short sentence.
- Use a GitHub permalink to the profile file, not a branch link.
- Use the selected release tag as `<permalink-ref>`, for example `v1.2.3` or `v1.3.0-rc.1`.
- When drafting the new release section before the tag exists remotely, still write the final release-tag link into `CHANGELOG.md`.

## Output Shape

Use plain markdown bullets under these headings when they have content:

```md
### Upgrade Notes

- ...

### Features

- ...

### Bug Fixes

- ...

### Chores

- ...

### Misc

- ...

### Changed Sandboxing Profiles

- [`profiles/...`](https://github.com/eugene1g/agent-safehouse/blob/<permalink-ref>/profiles/...): What changed and why.
```

If a section has nothing worth shipping, omit filler bullets in the final release notes.
Inside `## [Unreleased]`, only use placeholder text for `Upgrade Notes` and `Changed Sandboxing Profiles`.

Do not retrofit old releases to add `Upgrade Notes`, `Chores`, or `Changed Sandboxing Profiles` just because the current release uses those headings.
