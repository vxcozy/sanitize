#!/usr/bin/env bash
# ─── Install sanitization pre-commit hook into git repos ─────────────────────
# Usage:  ./install-hooks.sh /path/to/repo [/path/to/another ...]
#         ./install-hooks.sh                # installs into current directory
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK_SRC="$SCRIPT_DIR/pre-commit-sanitize"

if [ ! -f "$HOOK_SRC" ]; then
  echo "Error: pre-commit-sanitize not found in $SCRIPT_DIR"
  exit 1
fi

install_hook() {
  local repo="$1"

  if [ ! -d "$repo/.git" ]; then
    echo "  skip  $repo (not a git repository)"
    return
  fi

  local dest="$repo/.git/hooks/pre-commit"

  if [ -f "$dest" ]; then
    echo "  update  $repo (replacing existing hook)"
  else
    echo "  install $repo"
  fi

  cp "$HOOK_SRC" "$dest"
  chmod +x "$dest"
}

echo ""
echo "Installing 12-point sanitization pre-commit hook..."
echo ""

if [ $# -eq 0 ]; then
  install_hook "."
else
  for repo in "$@"; do
    install_hook "$repo"
  done
fi

echo ""
echo "Done. The hook runs automatically on git commit."
echo "Bypass with: git commit --no-verify"
echo ""
