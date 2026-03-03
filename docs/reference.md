# Reference

Complete specification of every check, pattern, and behavior in the sanitize hook.

## Exit codes

| Code | Meaning |
|------|---------|
| `0` | All checks passed (or passed with warnings) |
| `1` | One or more checks failed — commit blocked |

## Check severity

| Severity | Behavior |
|----------|----------|
| **block** | Fails the check, increments error count, blocks commit (exit 1) |
| **warn** | Flags the finding, increments warning count, allows commit (exit 0) |
| **info** | Informational only, no impact on pass/fail |

## Checks

### 1. Full file audit (info)

Lists all staged files. Informational only.

**Source**: `git diff --cached --name-only --diff-filter=ACM`

---

### 2. Private keys / mnemonics (block)

**Patterns** (case-insensitive, scans added lines only):

| Pattern | Catches |
|---------|---------|
| `0x[0-9a-fA-F]{64}` | Ethereum/hex private keys |
| `BEGIN.*(PRIVATE\|RSA\|EC\|DSA)\s*KEY` | PEM private keys |
| `mnemonic\s*[=:]` | Mnemonic assignments |
| `seed.?phrase\s*[=:]` | Seed phrase assignments |

---

### 3. API keys / tokens / secrets (block)

**Patterns** (case-insensitive):

| Pattern | Service |
|---------|---------|
| `sk-[a-zA-Z0-9_-]{20,}` | Anthropic, Stripe, OpenAI |
| `sk_live_[a-zA-Z0-9]+` | Stripe live keys |
| `AKIA[0-9A-Z]{16}` | AWS access keys |
| `ghp_[a-zA-Z0-9]{36}` | GitHub personal access tokens |
| `glpat-[a-zA-Z0-9_-]{20,}` | GitLab personal access tokens |
| `xox[bpsa]-[a-zA-Z0-9_-]+` | Slack tokens |

---

### 4. .env files (block)

**Matches staged files**: filenames matching `^\.env($|\.)` excluding `.example` suffix.

Catches: `.env`, `.env.local`, `.env.production`, etc.
Allows: `.env.example`

---

### 5. .mcp.json (block)

**Matches staged files**: any file path ending in `.mcp.json`.

These files commonly contain plaintext private keys for MCP server configurations.

---

### 6. Config files with secrets (block or warn)

**Stage 1** — matches filenames: `(config|settings|credentials)\.(json|ya?ml|toml)$`

**Stage 2** — if matched, scans file content for: `private.?key`, `secret`, `password`, `token\s*[=:"]`

- **block**: config file contains secret-like values
- **warn**: config file staged but no secrets detected

---

### 7. Plaintext passwords (block)

**Pattern**: `(password|passwd|pwd)\s*[=:]\s*["'][^"']{2,}`

**Excludes** (not flagged): references to environment variables (`process.env`, `env.`, `getenv`, `os.environ`, `${`), and placeholder values (`placeholder`, `example`, `changeme`, `your_`).

---

### 8. RPC URLs with embedded keys (block)

**Pattern**: URLs containing `infura`, `alchemy`, `quicknode`, `chainnodes`, or `moralis` domains followed by a path segment of 20+ alphanumeric characters.

Example match: `https://arb-mainnet.g.alchemy.com/v2/AbCdEfGhIjKlMnOpQrStUvWx`

---

### 9. Wallet addresses in non-test source (warn)

Scans non-test staged files for Ethereum addresses (`0x` + 40 hex chars).

**Excluded files**: `*.test.*`, `*.spec.*`, `__test__`, `__mock__`, `fixture`, `mock`

**Excluded addresses**: `0x0000...` (zero address), `0xaAaA...` (repeating), `0xdead...`, `0xbeef...`

This check only warns — wallet addresses in source may be legitimate (contract addresses, constants).

---

### 10. console.log leaking data (warn)

**Pattern**: `console.(log|debug|info|warn)` calls containing keywords: `key`, `secret`, `token`, `password`, `private`, `mnemonic`, `credential`.

---

### 11. .gitignore coverage (block)

Verifies `.gitignore` contains entries for:

- `.env`
- `.mcp.json`
- `config.json`
- `.claude`
- `node_modules`

Fails if `.gitignore` is missing entirely or any required pattern is absent.

---

### 12. Test files with real credentials (block)

Scans staged test files (`*.test.*`, `*.spec.*`) for production key patterns:

| Pattern | Service |
|---------|---------|
| `sk-[a-zA-Z0-9]{20,}` | Anthropic/Stripe/OpenAI |
| `AKIA[0-9A-Z]{16}` | AWS |
| `ghp_[a-zA-Z0-9]{36}` | GitHub |
| `real[_-]?(key\|token\|secret)` | Generic real credential labels |

## File structure

```
sanitize/
  scripts/
    pre-commit-sanitize    # The git hook (copy to .git/hooks/pre-commit)
    install-hooks.sh       # Bulk installer
  .claude/
    commands/
      sanitize.md          # Claude Code /sanitize skill
  docs/
    tutorial.md            # Getting started
    how-to.md              # Practical recipes
    reference.md           # This file
    explanation.md         # Design decisions
```

## Scope

The hook only scans **added/modified lines** in staged files — not the entire repository. This means:

- Existing code is not re-scanned on every commit
- Only new content is checked
- The hook is fast even in large repos

The Claude Code `/sanitize` skill scans the **entire repository** for a more thorough audit.
