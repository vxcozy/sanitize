# Tutorial: Getting started with sanitize

This tutorial walks you through installing and using the sanitize pre-commit hook in a git repository. By the end, you'll have automatic secret detection running on every commit.

## Prerequisites

- A git repository
- Bash (macOS, Linux, or WSL on Windows)
- Node.js (for `npx skills` — optional)

## Step 1: Install

### Option A: Agent skill (recommended)

If you use Claude Code, Cursor, Copilot, or any tool supporting [Agent Skills](https://agentskills.io):

```bash
npx skills add vxcozy/sanitize
```

This installs the `/sanitize` slash command into your project. Skip to Step 5 to use it.

### Option B: Pre-commit hook

```bash
git clone https://github.com/vxcozy/sanitize.git
cd sanitize
```

## Step 2: Install the hook into your project

```bash
./scripts/install-hooks.sh /path/to/your/project
```

You should see:

```
Installing 12-point sanitization pre-commit hook...

  install /path/to/your/project

Done. The hook runs automatically on git commit.
Bypass with: git commit --no-verify
```

## Step 3: Make a commit

Go to your project and commit something:

```bash
cd /path/to/your/project
echo "hello" > test.txt
git add test.txt
git commit -m "test commit"
```

You'll see the 12-point checklist run:

```
Pre-commit: 12-point sanitization

  [ 1/12] Staged files                                     1 file(s)
         test.txt

  [ 2/12] Private keys / mnemonics                         pass
  [ 3/12] API keys / tokens / secrets                      pass
  ...
  [12/12] Test files with real credentials                 pass

  All 12 checks passed
```

## Step 4: See it block a secret

Create a file with a fake API key:

```bash
echo 'API_KEY = "sk-test-abcdefghijklmnopqrstuvwxyz123"' > bad.txt
git add bad.txt
git commit -m "oops"
```

The hook blocks the commit:

```
  [ 3/12] API keys / tokens / secrets                      FAIL
         API_KEY = "sk-test-abcdefghijklmnopqrstuvwxyz123"

  BLOCKED: 1 check(s) failed
  Fix the issues above or bypass with: git commit --no-verify
```

Remove the secret, then commit normally:

```bash
rm bad.txt
git reset HEAD bad.txt
```

## Step 5: Use the /sanitize skill

If you installed via `npx skills add` (Step 1A), the `/sanitize` command is already available.

Run `/sanitize` in your AI coding tool for an interactive audit that scans your entire repository with detailed file:line references.

## Next steps

- Read the [how-to guides](how-to.md) for specific tasks like customizing patterns or installing across multiple repos
- See the [reference](reference.md) for the full list of patterns and configuration
- Read the [explanation](explanation.md) to understand why each check exists
