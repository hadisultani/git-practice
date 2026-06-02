# 12 — Reflog

## What the reflog is

The reflog (reference log) is git's safety net. It records every position
HEAD has been at — every commit, checkout, reset, rebase, and merge —
even operations that "erase" commits from normal history.

While `git log` shows you the history of the project,
`git reflog` shows you the history of where you have been.

```
git log:    A ── B ── C           (what exists in the repo now)
git reflog: C, B, C, D, C, B...  (everywhere HEAD has pointed, newest first)
```

The reflog is local — it is not pushed to GitHub and is not shared with teammates.
Entries expire after 90 days by default.

---

## 1. Reading the reflog

```bash
git reflog
```

Output:

```
c2b772d HEAD@{0}  commit: fix: fix README
549a918 HEAD@{1}  commit: docs: add security notes
99fc0c4 HEAD@{2}  merge: Merge pull request #3
f728d79 HEAD@{3}  commit: docs: add more useful configs
17a64fa HEAD@{4}  merge: Merge pull request #2
abc1234 HEAD@{5}  reset: moving to HEAD~1
def5678 HEAD@{6}  commit: feat: add login form
```

- `HEAD@{0}` = where HEAD is right now
- `HEAD@{1}` = where HEAD was one move ago
- `HEAD@{N}` = N moves ago

---

## 2. Recovering from a bad git reset --hard

This is the most common rescue scenario. You ran `git reset --hard` and
lost commits you actually wanted.

```bash
# You ran this and regret it
git reset --hard HEAD~3

# Find the lost commits in the reflog
git reflog
# HEAD@{1}: commit: feat: add important feature   ← this is what you want

# Restore to that point
git reset --hard HEAD@{1}

# Or create a new branch at that point (safer — preserves current state)
git branch recovered-work HEAD@{1}
git switch recovered-work
```

---

## 3. Recovering a deleted branch

If you deleted a branch that wasn't fully merged:

```bash
# Branch was deleted — commits seem gone
git branch -D feature/my-feature

# Find the last commit that was on that branch
git reflog
# HEAD@{4}: checkout: moving from feature/my-feature to main
#           ↑ the commit before this checkout is the tip of the deleted branch

# Recreate the branch at that commit
git branch feature/my-feature HEAD@{5}
# or use the commit hash directly
git branch feature/my-feature abc1234
```

---

## 4. Recovering from a bad rebase

Interactive rebase can sometimes leave your commits in an unexpected state.
The reflog captures the state before the rebase began.

```bash
# You rebased and the result is wrong
git rebase -i origin/main

# Find where you were before the rebase
git reflog
# HEAD@{6}: rebase (start): checkout origin/main
#           ↑ everything before this line is pre-rebase

# Go back to pre-rebase state
git reset --hard HEAD@{7}   # one entry before the rebase started
```

---

## 5. Reflog for a specific branch

The reflog tracks every ref, not just HEAD.

```bash
# Reflog for a specific branch
git reflog show main
git reflog show feature/my-feature

# Reflog with timestamps
git reflog --date=iso
git reflog --date=relative   # "2 hours ago", "yesterday"
```

---

## 6. The expiry window

Reflog entries are not kept forever.

| Entry type | Default expiry |
|---|---|
| Reachable commits (still in some branch) | 90 days |
| Unreachable commits (orphaned) | 30 days |

After expiry, entries are pruned during `git gc` (garbage collection).
This runs automatically in the background.

```bash
# See the expiry configuration
git config --global gc.reflogExpire
git config --global gc.reflogExpireUnreachable

# Change the default (e.g. keep unreachable for 60 days)
git config --global gc.reflogExpireUnreachable 60.days
```

> The 30-day window for unreachable commits means you have at least a month
> to recover from almost any mistake before the data is truly gone.

---

## 7. Finding a commit by searching the reflog

```bash
# Search reflog for a specific message
git log --walk-reflogs --grep="login form"

# Show reflog as a graph
git log --walk-reflogs --oneline --graph

# Show all commits reachable from the reflog (includes orphaned commits)
git fsck --lost-found
# Orphaned commits appear in .git/lost-found/commit/
```

---

## Quick reference

```bash
# View the reflog
git reflog
git reflog --date=relative

# Recover from a bad reset
git reset --hard HEAD@{N}

# Recover a deleted branch
git branch recovered-branch HEAD@{N}

# Find where you were before a rebase
git reflog
git reset --hard HEAD@{N}   # go back to pre-rebase state

# Reflog for a specific branch
git reflog show branch-name
```
