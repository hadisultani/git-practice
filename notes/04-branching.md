# 04 — Branching

## What a branch is

A branch is just a lightweight pointer to a commit. Creating a branch
does not copy any files — it creates a 41-byte file containing a commit hash.

```
main:    A ── B ── C           ← HEAD points here
                   ↑
                (just a pointer)

git checkout -b feature/x

main:    A ── B ── C           ← main still points here
feature:           C           ← feature/x also points here (same commit)
                   ↑
                 HEAD
```

As you commit on the feature branch, the pointer moves forward.
Main stays exactly where it was.

---

## 1. Creating branches

```bash
# Create and switch in one step (classic)
git checkout -b feature/my-feature

# Create and switch in one step (modern)
git switch -c feature/my-feature

# Create from a specific branch (not current)
git checkout -b feature/my-feature main

# Create from a specific commit
git checkout -b feature/my-feature abc1234

# Create from a tag
git checkout -b hotfix/payment v2.1.0

# Create without switching (stays on current branch)
git branch feature/my-feature
```

---

## 2. Switching branches

```bash
# Classic
git checkout main
git checkout feature/my-feature

# Modern (clearer intent)
git switch main
git switch feature/my-feature

# Switch to previous branch (like cd -)
git checkout -
git switch -
```

### What happens when you switch

- Git updates your working tree to match the target branch
- Uncommitted changes travel with you if they don't conflict
- If there's a conflict git refuses to switch

```bash
# If git refuses to switch due to uncommitted changes
git stash                           # shelve changes
git switch main                     # switch safely
git stash pop                       # restore changes on new branch
```

---

## 3. Listing branches

```bash
git branch                          # local branches only
git branch -r                       # remote-tracking branches only
git branch -a                       # all branches (local + remote)
git branch -v                       # local branches with last commit message
git branch -vv                      # also shows tracking relationship
```

### Reading branch -vv output

```
* feature/my-feature  abc1234 [origin/feature/my-feature] feat: add login
  main                def5678 [origin/main] docs: update README
```

- `*` = current branch
- `[origin/...]` = what remote branch it tracks
- If it shows `ahead 2` or `behind 3` = how far out of sync you are

---

## 4. Tracking remote branches

When you push a branch with `-u` it sets up tracking — git then knows
which remote branch to push to and pull from automatically.

```bash
# First push — set upstream tracking
git push -u origin feature/my-feature
# Now plain "git push" and "git pull" work from this branch

# Check tracking relationships
git branch -vv

# Set tracking manually (if you forgot -u)
git branch --set-upstream-to=origin/feature/my-feature feature/my-feature
# shorter:
git branch -u origin/feature/my-feature

# Check out a remote branch that doesn't exist locally yet
git fetch origin
git checkout feature/their-branch          # git auto-tracks origin/feature/their-branch
# or explicitly:
git checkout -b feature/their-branch origin/feature/their-branch
```

---

## 5. git checkout in depth

`git checkout` is one of git's oldest commands — it does three different
jobs, which is why git 2.23 split it into `switch` and `restore`.

### Job 1 — switching branches

```bash
git checkout main
git checkout -b feature/x              # create + switch
git checkout -b feature/x main         # create from main + switch
git checkout -                         # switch to previous branch
```

### Job 2 — detached HEAD (inspecting history)

```bash
git checkout abc1234                   # go to a specific commit
git checkout HEAD~3                    # go back 3 commits
git checkout v1.0.0                    # go to a tagged release
```

Puts you in **detached HEAD** state — you're not on any branch,
just looking at a point in history.

```
Normal:    HEAD → main → abc1234
Detached:  HEAD → abc1234  (no branch pointer)
```

Useful for inspecting old code or testing an older version.
If you make commits in detached HEAD, create a branch to keep them:

```bash
git checkout -b rescue-branch          # attach HEAD before switching away
```

> If you switch away without creating a branch, any commits made in
> detached HEAD are orphaned and eventually garbage collected.

### Job 3 — discarding file changes

```bash
git checkout -- README.md              # discard unstaged changes to one file
git checkout -- .                      # discard ALL unstaged changes
```

> ⚠️ Permanent — discarded changes cannot be recovered.
> Only affects unstaged changes. Staged changes are unaffected.

### Modern replacements (git 2.23+)

```bash
# Switching → git switch
git switch main                        # replaces: git checkout main
git switch -c feature/x               # replaces: git checkout -b feature/x
git switch --detach abc1234           # replaces: git checkout abc1234
git switch -                          # replaces: git checkout -

# Discarding → git restore
git restore README.md                  # replaces: git checkout -- README.md
git restore .                          # replaces: git checkout -- .
git restore --staged README.md        # unstage a file (no checkout equivalent)
```

| Command | Use when |
|---|---|
| `git checkout` | Reading others' code, older tutorials, muscle memory |
| `git switch` | Your own work — clearer intent, harder to misuse |
| `git restore` | Discarding changes — explicit and safe |

---

## 6. Deleting branches

```bash
# Delete local branch (safe — refuses if unmerged)
git branch -d feature/my-feature

# Force delete local branch (even if unmerged)
git branch -D feature/my-feature

# Delete remote branch
git push origin --delete feature/my-feature

# Delete remote branch (shorthand)
git push origin :feature/my-feature

# Prune stale remote-tracking refs (branches deleted on GitHub but still listed locally)
git fetch --prune
# or set it to always prune automatically:
git config --global fetch.prune true
```

---

## 7. Renaming a branch

```bash
# Rename current branch
git branch -m new-name

# Rename a specific branch
git branch -m old-name new-name

# Push renamed branch and update tracking
git push origin -u new-name

# Delete the old name on remote
git push origin --delete old-name
```

---

## 8. Branching strategies

Different teams use different conventions for how branches are named
and how they relate to each other.

### GitHub Flow (simple — good for most teams)

```
main        → always deployable, protected
feature/*   → all work branches, PR back to main
hotfix/*    → urgent fixes, PR back to main
```

```bash
git switch -c feature/user-auth
# work, commit, push
gh pr create --base main
# PR reviewed, squash merged, branch deleted
```

Best for: continuous deployment, small-medium teams, SaaS products.

### Git Flow (structured — good for versioned releases)

```
main        → production releases only, tagged
develop     → integration branch, next release
feature/*   → branch from develop, PR back to develop
release/*   → branch from develop, merged to main + develop
hotfix/*    → branch from main, merged to main + develop
```

Best for: mobile apps, libraries, products with scheduled releases.

### Trunk Based Development

```
main        → everyone merges here daily
feature/*   → very short-lived (hours not days), or use feature flags
```

Best for: large teams, CI/CD pipelines, Google/Meta style engineering.

### Branch naming conventions

```bash
feature/short-description       # new functionality
fix/short-description           # bug fixes
hotfix/short-description        # urgent production fixes
chore/short-description         # maintenance, dependencies, tooling
docs/short-description          # documentation only
release/v1.2.0                  # release preparation
```

---

## 9. Useful branch aliases

```bash
# Create branch from latest main in one command
git config --global alias.nb '!git checkout main && git pull && git checkout -b'
git nb feature/my-feature        # pulls main then creates branch

# List branches sorted by most recently used
git config --global alias.recent 'branch --sort=-committerdate -vv'
git recent

# Clean up all merged local branches
git config --global alias.cleanup '!git branch --merged main | grep -v "main" | xargs git branch -d'
git cleanup
```

---

## Quick reference

```bash
# Create and switch
git switch -c feature/my-feature          # from current branch
git switch -c feature/my-feature main     # from main

# List
git branch -vv                            # local with tracking info
git branch -a                             # all including remote

# Push and track
git push -u origin feature/my-feature    # first push — sets tracking

# Delete
git branch -d feature/my-feature         # local (safe)
git push origin --delete feature/my-feature  # remote
git fetch --prune                         # clean up stale remote refs

# Inspect history (detached HEAD)
git switch --detach abc1234              # look at old commit safely
git switch -c rescue-branch             # create branch to keep any work

# Discard changes
git restore filename                     # discard unstaged changes to file
git restore .                            # discard all unstaged changes
git restore --staged filename            # unstage a file
```
