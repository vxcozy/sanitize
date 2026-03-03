# sanitize

A 12-point pre-commit hook and Claude Code skill that blocks secrets, credentials, and sensitive data from being committed to git.

## What it catches

| # | Check | Severity |
|---|-------|----------|
| 1 | Full file audit | info |
| 2 | Private keys / mnemonics | block |
| 3 | API keys / tokens / secrets | block |
| 4 | `.env` files | block |
| 5 | `.mcp.json` files | block |
| 6 | `config.json` with secrets | block/warn |
| 7 | Plaintext passwords | block |
| 8 | RPC URLs with embedded keys | block |
| 9 | Wallet addresses in non-test files | warn |
| 10 | `console.log` leaking sensitive data | warn |
| 11 | `.gitignore` coverage gaps | block |
| 12 | Test files with real credentials | block |

## Quick start

```bash
# Install into a repo
./scripts/install-hooks.sh /path/to/your/repo

# Or install into multiple repos at once
./scripts/install-hooks.sh ./repo-a ./repo-b ./repo-c
```

The hook runs automatically on every `git commit`. Bypass with `git commit --no-verify` when needed.

## Claude Code skill

Copy `.claude/commands/sanitize.md` into your project's `.claude/commands/` directory. Then run `/sanitize` in Claude Code for an interactive full-repo audit.

## Documentation

- [Tutorial: Getting started](docs/tutorial.md)
- [How-to guides](docs/how-to.md)
- [Reference](docs/reference.md)
- [Explanation](docs/explanation.md)

## License

MIT
