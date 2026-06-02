# 05 — Undoing Things

## The four tools and when to use each

| Tool | What it does | Safe after push? |
|---|---|---|
| `git commit --amend` | Rewrite the last commit | No |
| `git reset` | Move HEAD backward, optionally unstage/discard | No (on shared branches) |
| `git revert` | Create a new commit that undoes a previous one | Yes |
| `git stash` | Temporarily shelve uncommitted changes | Yes (local only) |
| `git restore --source` | Pull a single file back from a past commit | Yes |
| `git clean` | Delete untracked files from the working tree | Yes (local only) |

---

## 1. Amend — fix the last commit

Use when you forgot a file, made a typo in the message, or want to tweak
the last commit before pushing.

```bash
# Fix the commit message only
git commit --amend
# opens VS Code — edit the message, save, close

# Add a forgotten file (keep same message)
git add forgotten-file.md
git commit --amend --no-edit

# Check the result
git log --oneline
```

> ⚠️ Amend rewrites the commit hash. Never amend after pushing —
> anyone who pulled the old hash now has a different history than you.

---

## 2. Reset — move HEAD backward

Reset moves the HEAD pointer back to a previous commit.
The key is understanding the three modes.

```
Commit history:   A ── B ── C  ← HEAD
After reset to B: A ── B  ← HEAD   (C is gone from history)
```

### The three modes

```bash
git reset --soft HEAD~1     # undo last commit, keep changes STAGED
git reset --mixed HEAD~1    # undo last commit, keep changes UNSTAGED (default)
git reset --hard HEAD~1     # undo last commit, DISCARD changes entirely
```

### What each mode leaves behind

```
                        Staged    Working tree
--soft HEAD~1           YES       YES          ← safest, changes ready to re-commit
--mixed HEAD~1          NO        YES          ← default, changes back to unstaged
--hard HEAD~1           NO        NO           ← nuclear, changes are gone
```

### Common reset patterns

```bash
# Undo last commit, keep work staged (ready to re-commit differently)
git reset --soft HEAD~1

# Undo last commit, put changes back in working tree (unstaged)
git reset --mixed HEAD~1

# Undo last 3 commits, keep the work unstaged
git reset --mixed HEAD~3

# Go back to a specific commit (use hash from git log)
git reset --mixed abc1234

# Nuclear — throw away last commit AND all its changes
git reset --hard HEAD~1

# Nuclear — throw away ALL local changes back to last commit
git reset --hard HEAD
```

### HEAD~N shorthand

```bash
HEAD        # current commit
HEAD~1      # one commit back  (also written HEAD^)
HEAD~2      # two commits back
HEAD~3      # three commits back
abc1234     # any specific commit hash
```

> ⚠️ --hard is permanent for uncommitted changes. There is no undo.
> Only use it when you are certain you want to discard the work.
> git reflog can recover reset commits — see 12-reflog.md.

---

## 3. Revert — the safe public undo

Revert creates a NEW commit that applies the inverse of a previous commit.
The original commit stays in history — nothing is rewritten.

```bash
# Revert the last commit
git revert HEAD

# Revert a specific commit by hash
git revert abc1234

# Revert without auto-opening the editor (use default message)
git revert HEAD --no-edit

# Revert but don't commit yet (stage the revert for review first)
git revert HEAD --no-commit
git status           # see what the revert changed
git commit -m "revert: undo X because Y"
```

### Revert vs reset — the key difference

```
reset:   A ── B ── C          becomes   A ── B
                                         (C is erased)

revert:  A ── B ── C          becomes   A ── B ── C ── C'
                                         (C' undoes what C did)
```

> Use revert on any branch that has been pushed or that others
> are working from. It is the only safe way to undo public history.

---

## 4. Stash — shelve work temporarily

Stash saves your uncommitted changes to a temporary stack so you can
switch context (fix a bug, pull updates, change branches) and come back.

```bash
# Stash everything (tracked files only by default)
git stash

# Stash with a descriptive name (recommended)
git stash push -m "half-finished login form"

# Stash including untracked files
git stash push --include-untracked -m "work in progress"

# List all stashes
git stash list
# stash@{0}: On main: half-finished login form
# stash@{1}: On feature/auth: work in progress

# Apply most recent stash (keeps it in the stash list)
git stash apply

# Apply most recent stash and remove from list
git stash pop

# Apply a specific stash by index
git stash apply stash@{1}

# See what's in a stash before applying
git stash show stash@{0}
git stash show stash@{0} -p     # full diff

# Delete a specific stash
git stash drop stash@{0}

# Delete all stashes
git stash clear
```

### Common stash workflow

```bash
# You're mid-work when an urgent bug comes in
git stash push -m "feature half done"

# Switch to main, fix the bug
git checkout main
git checkout -b fix/urgent-bug
# ... fix, commit, push, PR ...

# Come back to your feature
git checkout feature/my-feature
git stash pop                    # your work is back exactly as you left it
```

> stash@{0} is always the most recent stash.
> stash is local only — it never gets pushed to GitHub.

---

## 5. restore --source — pull a file back from history

Use when you want to recover a specific file from a past commit without
reverting or resetting the whole branch. The rest of your history is untouched.

```bash
# Restore a file to how it looked N commits ago
git restore --source=HEAD~1 -- config.yml

# Restore from a specific commit hash
git restore --source=abc1234 -- src/auth.js

# Restore a file that was deleted in a past commit
git log --oneline -- deleted-file.md         # find the last commit that had it
git restore --source=abc1234 -- deleted-file.md
```

The file lands in your working tree as an unstaged change — review it,
then stage and commit as normal.

> Unlike `git checkout` (which can accidentally switch branches), `git restore`
> only ever touches files — it is impossible to accidentally detach HEAD with it.

---

## 6. clean — remove untracked files

Removes files that are not tracked by git — things that were never added or
committed. Useful after a build that scattered output files, or when you want
to reset your working tree completely.

```bash
# Dry run first — see what WOULD be deleted without deleting anything
git clean -n

# Delete untracked files (but not directories)
git clean -f

# Delete untracked files AND untracked directories
git clean -fd

# Also delete files ignored by .gitignore (build output, caches, etc.)
git clean -fdx

# Interactive — approve each file before deleting
git clean -i
```

> ⚠️ `git clean` is permanent — deleted files cannot be recovered with git.
> Always run `git clean -n` first to preview what will be removed.

### clean vs reset --hard

| Command | Removes committed changes? | Removes staged changes? | Removes untracked files? |
|---|---|---|---|
| `git reset --hard HEAD` | Yes | Yes | No |
| `git clean -fd` | No | No | Yes |
| Both together | Yes | Yes | Yes |

Running both is the "nuclear full reset" — your working tree matches the last
commit exactly with nothing extra lying around.

---

## Decision guide — which tool to use?

```
Did you push already?
├── YES → git revert (never rewrite public history)
└── NO
    ├── Want to fix/extend the last commit? → git commit --amend
    ├── Want to undo commit(s) but keep the work?
    │   ├── Keep staged   → git reset --soft HEAD~N
    │   └── Keep unstaged → git reset --mixed HEAD~N
    ├── Want to throw the work away entirely? → git reset --hard HEAD~N
    ├── Want to set work aside temporarily? → git stash
    ├── Want one specific file back from history? → git restore --source=<commit> -- file
    └── Want to delete untracked files? → git clean -fd
```
