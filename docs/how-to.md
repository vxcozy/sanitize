# How-to guides

Practical recipes for common tasks with sanitize.

## Install into multiple repos at once

```bash
./scripts/install-hooks.sh ./repo-a ./repo-b ./repo-c
```

The installer skips non-git directories and reports which repos it installed into.

## Update the hook in existing repos

Re-run the installer. It overwrites the existing hook:

```bash
./scripts/install-hooks.sh /path/to/your/repo
```

Output shows `update` instead of `install`:

```
  update  /path/to/your/repo (replacing existing hook)
```

## Bypass the hook for a single commit

Use git's built-in `--no-verify` flag:

```bash
git commit --no-verify -m "skip checks this once"
```

This skips all pre-commit hooks, not just sanitize. Use with caution.

## Add custom patterns to detect

Edit `scripts/pre-commit-sanitize` and add patterns to the relevant check. For example, to catch a custom token format:

```bash
# In check 3 (API keys), add your pattern to the grep:
HITS=$(echo "$DIFF" | grep -Ei '(sk-[a-zA-Z0-9_-]{20,}|YOUR_CUSTOM_PATTERN)' ...)
```

## Add files to the .gitignore coverage check

Edit check 11 in the hook script. Find the `for pat in` line and add your pattern:

```bash
for pat in ".env" ".mcp.json" "config.json" ".claude" "node_modules" "your-file"; do
```

## Use only the Claude Code skill (without the git hook)

Copy just the skill file:

```bash
mkdir -p /path/to/your/project/.claude/commands
cp .claude/commands/sanitize.md /path/to/your/project/.claude/commands/
```

Run `/sanitize` in Claude Code. The skill works independently — it instructs Claude to run the same checks by reading and grepping your repo.

## Uninstall the hook

Delete the pre-commit hook from your repo:

```bash
rm /path/to/your/repo/.git/hooks/pre-commit
```

## Handle false positives

The hook may flag legitimate patterns. Common cases:

**Test files with dummy keys**: The hook checks test files (check 12) only for patterns like `sk-*`, `AKIA*`, `ghp_*`. Dummy values like `"test-key"` or `"0xdead..."` won't trigger it.

**Wallet addresses in source**: Check 9 only warns (doesn't block). Addresses in test files are excluded. If you have legitimate addresses in source (like contract addresses), the warning is informational only.

**Config files without secrets**: Check 6 warns when config files are staged but only blocks if they contain secret-like values (`private_key`, `secret`, `password`, `token`).

## Run the hook manually (without committing)

Stage your files and run the hook script directly:

```bash
git add .
.git/hooks/pre-commit
```

This runs all 12 checks without creating a commit.
