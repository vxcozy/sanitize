# Explanation

Why sanitize exists, how it works, and the thinking behind its design.

## The problem

Accidentally committing secrets to git is one of the most common security mistakes. Once a secret hits a remote repository, it's effectively compromised — git history is permanent, bots scrape public repos continuously, and rotating credentials after exposure is costly and disruptive.

Common accidents include:

- Committing `.env` files with real API keys
- Hardcoding a private key "just for testing" and forgetting to remove it
- Pasting an RPC URL with an embedded API key into source code
- Leaving real credentials in test files
- Committing MCP configuration files that contain plaintext secrets

## Why a pre-commit hook

Pre-commit hooks are the last line of defense before code enters git history. They run automatically, require no extra tooling beyond bash, and block the commit before any secret touches the repository.

Compared to alternatives:

- **Code review**: catches secrets too late (already in history)
- **CI/CD scanning**: runs after push, secret is already exposed
- **IDE plugins**: depend on individual developer setup
- **`.gitignore`**: only prevents tracking, doesn't catch inline secrets

The hook complements all of these — it's the safety net that catches what other methods miss.

## Why these 12 checks

Each check addresses a specific class of secret leak:

**Checks 2-3 (keys/tokens)**: The most dangerous leaks. Private keys and API tokens grant direct access to systems and funds. The patterns target known token formats (Anthropic `sk-*`, AWS `AKIA*`, GitHub `ghp_*`, etc.) rather than generic heuristics to minimize false positives.

**Checks 4-6 (files)**: Certain files should never be committed regardless of content. `.env` files contain environment-specific secrets. `.mcp.json` files contain plaintext private keys. `config.json` files frequently contain secrets and should be reviewed.

**Check 7 (passwords)**: Catches hardcoded passwords while excluding references to environment variables and placeholder values.

**Check 8 (RPC URLs)**: Specific to web3/blockchain development where RPC provider URLs often embed API keys directly in the path.

**Check 9 (wallet addresses)**: A soft check (warn, not block) that flags real Ethereum addresses in non-test source. Useful for catching personal addresses accidentally committed, while allowing legitimate constants like contract addresses.

**Check 10 (console.log)**: Debug logging that references sensitive variables is a subtle leak vector — it can expose secrets in browser consoles, server logs, or error reporting services.

**Check 11 (.gitignore)**: Preventive rather than detective. Ensures the `.gitignore` has entries for all common secret-bearing files. Missing entries mean future commits could accidentally track those files.

**Check 12 (test credentials)**: Test files often receive less scrutiny but are equally dangerous. Real API keys in tests get committed "because they work" and forgotten.

## Design decisions

### Scan only added lines

The hook scans `git diff --cached` (added/modified lines) rather than entire files. This means:

- It's fast, even in large repos
- It doesn't flag existing code that predates the hook
- It focuses on what's changing right now

The Claude Code `/sanitize` skill fills the gap by scanning the entire repo on demand.

### Block vs warn

Checks are either **block** (exit 1, commit prevented) or **warn** (exit 0, commit allowed). The distinction:

- **Block**: high-confidence patterns that are almost certainly secrets (API keys, private keys, .env files)
- **Warn**: patterns that might be intentional (wallet addresses in source, console.log with "key" in the message)

This reduces false-positive friction while catching real secrets.

### No configuration file

The hook is a single self-contained bash script. No YAML, no JSON, no dependencies. This makes it:

- Easy to understand (read the script)
- Easy to customize (edit the script)
- Easy to share (copy one file)
- Portable (runs anywhere bash runs)

### Complementary skill

The Claude Code `/sanitize` skill provides a different angle: interactive, conversational, and thorough. It scans the entire repo (not just staged changes) and provides file:line references. It's for audits, not every-commit checks.

## Limitations

- The hook uses regex pattern matching, not semantic analysis. It can't distinguish a real key from a key-shaped string in documentation.
- Custom token formats require editing the script. The patterns cover common services but not every possible format.
- The hook runs in bash and assumes standard Unix tools (`grep`, `sed`, `wc`). It works on macOS, Linux, and WSL but not native Windows cmd.
- `.gitignore` check (11) looks for exact string matches, so `*.json` would not satisfy the `config.json` requirement even though it covers it.
