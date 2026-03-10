#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
INSTALL_PATH="${HOME}/.local/bin/safehouse"

cd "$REPO_DIR"

echo "Fetching upstream..."
git fetch upstream

echo "Rebasing on upstream/main..."
if ! git rebase upstream/main; then
  echo "Rebase conflict — resolve manually in ${REPO_DIR}" >&2
  exit 1
fi

echo "Regenerating dist binary..."
scripts/generate-dist.sh >/dev/null

echo "Installing to ${INSTALL_PATH}..."
cp dist/safehouse.sh "$INSTALL_PATH"
chmod 0755 "$INSTALL_PATH"

echo "Done. $(safehouse --version 2>/dev/null || echo 'safehouse updated')"
