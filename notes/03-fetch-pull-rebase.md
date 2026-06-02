# 03 — Fetch, Pull & Rebase

## The three locations

```
GitHub (origin)  ──git fetch──►  origin/main          ──git merge──►  main
                                 (remote-tracking,                    (your local
                                  lives on your machine)               branch)

GitHub (origin)  ──────────────────git pull────────────────────────►  main
                                   (fetch + merge in one step)
```

There are three distinct locations to keep straight:
1. **GitHub** — the actual remote server
2. **origin/main** — a local snapshot of GitHub's last known state (updated by fetch)
3. **main** — your working local branch

## git fetch — safe, look before you leap

Downloads new commits from GitHub into `origin/main` without touching your branch.

```bash
git fetch origin

# Now inspect what came in before merging
git status                              # shows "behind by N commits"
git log --oneline main..origin/main    # commits on remote not yet in local
git log --oneline origin/main..main    # your commits not yet on remote
git diff main origin/main              # actual line-by-line changes

# Only merge once you're happy with what's coming in
git merge origin/main
```

## git pull — fetch + merge in one step

```bash
git pull                  # merge-based (may create a merge commit)
git pull --rebase         # rebase-based (cleaner, linear history)
```

> For personal repos, `git pull` is fine.
> For team repos with many contributors, `git pull --rebase` is preferred.

## The .. log syntax

```bash
git log --oneline A..B    # commits in B that are NOT in A
```

| Command | Meaning |
|---|---|
| `git log --oneline main..origin/main` | What's on GitHub that I don't have yet |
| `git log --oneline origin/main..main` | What I have locally that isn't pushed yet |

## Rebase

Lifts your commits off their current base and replants them at the tip of
another branch. Same changes, new commit hashes (shown as D' and E' below).

```
Before:                          After rebase onto main:

main:    A ── B ── C             main:    A ── B ── C ── D' ── E'
feature: A ── D ── E
```

```bash
git fetch origin                    # get latest state of remote
git log --oneline --graph --all     # see the divergence
git rebase origin/main              # replay your commits on top
git log --oneline --graph --all     # confirm straight line, no merge commit
```

## Merge vs rebase

| Situation | Use |
|---|---|
| Keeping your feature branch current with main | Rebase |
| Merging a finished feature branch into main | Merge |
| Shared branch someone else is using | Merge only — never rebase |
| `git pull` on a team repo | `git pull --rebase` |

## The golden rule of rebase

> Never rebase a branch that other people are working from.

Rebase rewrites commit hashes. If a colleague pulled your branch before
you rebased it, their history and yours are now incompatible.

- Your own feature branch that only you use → rebase freely
- main, develop, or any shared branch → merge only

## Make rebase the default for pull

```bash
git config --global pull.rebase true
# Now plain "git pull" always rebases instead of creating a merge commit
```

> This chapter covers rebase as it relates to staying in sync with a remote.
> For the full rebase guide — interactive rebase, conflict resolution, force push,
> and the golden rule — see [06-rebase.md](06-rebase.md).
