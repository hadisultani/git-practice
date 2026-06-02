# 10 — .gitignore

## What it is

A `.gitignore` file tells git which files and folders to ignore — never stage,
never commit, never track. It lives in the root of your repository.

Common things to ignore:
- Build output and compiled files (`dist/`, `*.o`, `*.class`)
- Dependencies installed by package managers (`node_modules/`, `.venv/`)
- Editor and OS files (`.DS_Store`, `.vscode/`, `Thumbs.db`)
- Secrets and credentials (`.env`, `secrets.json`, `*.pem`)
- Log files and caches (`*.log`, `.cache/`)

```
Without .gitignore:               With .gitignore:
git status shows 500 files  →     git status shows only your code
node_modules/ gets committed →    only your source files are tracked
```

---

## 1. Creating a .gitignore

```bash
# Create at repo root
touch .gitignore

# Or let GitHub create one for you when creating a repo
# (choose a template based on your language)
```

The file is plain text — one pattern per line.

---

## 2. How patterns work

```
# Lines starting with # are comments

# Exact file name — ignores this file anywhere in the repo
secrets.json

# Wildcard — ignores all .log files anywhere
*.log

# Directory — the trailing slash means "directory only"
node_modules/
dist/
.cache/

# Specific path — only ignores this exact location
build/output.js

# Negation — re-include something that a broader pattern excluded
*.log
!important.log          # track this one log file despite the *.log rule

# Double-star — matches across directory levels
**/temp                 # matches temp/ anywhere in the tree
logs/**/*.log           # matches .log files in any subdirectory of logs/
```

### Pattern matching summary

| Pattern | Matches |
|---|---|
| `secrets.json` | That filename anywhere in the repo |
| `*.log` | Any file ending in `.log` anywhere |
| `build/` | A directory named `build` anywhere |
| `/build/` | Only a `build` directory at repo root |
| `!keep.log` | Un-ignores this specific file |
| `**/*.log` | Any `.log` file at any depth |
| `doc/*.txt` | `.txt` files directly inside `doc/` only |

---

## 3. Checking what is ignored

```bash
# Check if a specific file is ignored and why
git check-ignore -v node_modules
# .gitignore:3:node_modules/   node_modules

# Check multiple files at once
git check-ignore -v dist/ .env build/

# List all ignored files in the current directory
git status --ignored
```

---

## 4. Ignoring a file that is already tracked

`.gitignore` only works on **untracked** files. If you already committed a file,
adding it to `.gitignore` does nothing — git continues tracking it.

```bash
# Stop tracking a file without deleting it from disk
git rm --cached secrets.json

# Stop tracking an entire directory
git rm --cached -r node_modules/

# Then commit the removal
git commit -m "chore: stop tracking node_modules"
```

After this, add the file to `.gitignore` so it stays untracked.

> ⚠️ Even after removing from tracking, the file still exists in past commits.
> Anyone with repo access can see the old history.
> If you accidentally committed a secret, treat it as compromised — see 09-security.md.

---

## 5. Global gitignore — ignore across all repos

Some files are irrelevant to every project (`.DS_Store`, `.vscode/`, `Thumbs.db`).
Rather than adding them to every repo, put them in a global gitignore.

```bash
# Create the global gitignore file
touch ~/.gitignore_global

# Tell git to use it
git config --global core.excludesfile ~/.gitignore_global
```

Add to `~/.gitignore_global`:

```
# macOS
.DS_Store
.AppleDouble
.LSOverride

# Windows
Thumbs.db
ehthumbs.db
Desktop.ini

# VS Code
.vscode/
*.code-workspace

# JetBrains IDEs
.idea/
*.iml

# Python virtual environments
.venv/
venv/
__pycache__/
*.pyc

# Node
node_modules/
npm-debug.log*

# Misc
*.log
*.tmp
.env.local
```

---

## 6. Language-specific templates

GitHub maintains a collection of ready-made `.gitignore` templates for
every major language and framework at:

```
github.com/github/gitignore
```

You can also generate one at `gitignore.io` by typing in your tech stack.

Common starting points:

### Node.js

```
node_modules/
dist/
.env
npm-debug.log*
yarn-error.log*
.npm
coverage/
```

### Python

```
__pycache__/
*.py[cod]
*.egg-info/
dist/
build/
.venv/
venv/
.env
*.log
```

### macOS (add to global gitignore, not per-repo)

```
.DS_Store
.AppleDouble
.Spotlight-V100
.Trashes
```

---

## 7. .gitignore vs .gitkeep

Git does not track empty directories — if a folder has no files, git ignores it
entirely. To force git to track an empty directory, add a placeholder file:

```bash
touch build/.gitkeep
```

The file name `.gitkeep` is a convention, not a git feature. Any file works.

---

## Quick reference

```bash
# Create
touch .gitignore

# Check if a file is ignored
git check-ignore -v filename

# List all ignored files
git status --ignored

# Stop tracking a file that's already committed (keep file on disk)
git rm --cached filename
git rm --cached -r directory/

# Global gitignore setup
git config --global core.excludesfile ~/.gitignore_global
```
