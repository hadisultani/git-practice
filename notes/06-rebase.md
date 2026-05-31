# 06 — Rebase

## What rebase does

Rebase lifts your commits off their current base and replants them
at the tip of another branch. Your changes are identical — but the
commits are new objects with new hashes.

```
Before rebase:

main:    A ── B ── C
                   ↑
feature: A ── D ── E
         ↑
       (branched from here)

After: git rebase main (from feature branch):

main:    A ── B ── C
                   └── D' ── E'  ← same changes, new hashes
```

D' and E' contain exactly the same changes as D and E.
The prime (') means "same content, new commit object."

---

## 1. Basic rebase — keep your branch current with main

The most common use: you've been working on a feature branch while
main has moved ahead. Instead of a merge commit, rebase gives you
a clean linear history.

```bash
# From your feature branch
git fetch origin                        # get latest remote state
git log --oneline --graph --all         # see the divergence
git rebase origin/main                  # replay your commits on top

git log --oneline --graph --all         # confirm straight line
git push -u origin feature/my-branch   # push the rebased branch
```

### If conflicts arise during rebase

Rebase applies your commits one at a time. If one conflicts, it pauses
and asks you to resolve it before continuing.

```bash
# Rebase pauses with a conflict message
git status                    # shows conflicting files

# Open the conflicting file in VS Code and resolve the markers:
# <<<<<<< HEAD  (incoming from main)
# =======
# >>>>>>> your commit

git add resolved-file.md      # mark as resolved
git rebase --continue         # continue replaying remaining commits

# If you want to give up and go back to before the rebase
git rebase --abort
```

---

## 2. Interactive rebase — rewrite your commit history

Interactive rebase (`-i`) lets you edit, reorder, squash, or drop
commits before pushing. Useful for cleaning up messy work-in-progress
commits into a tidy, reviewable PR.

```bash
# Interactively rebase the last 3 commits
git rebase -i HEAD~3

# Interactively rebase everything since branching from main
git rebase -i origin/main
```

VS Code opens with a list of commits and actions:

```
pick abc1234 add login form
pick def5678 fix typo
pick ghi9012 fix another typo

# Commands:
# pick   = keep commit as-is
# reword = keep commit but edit the message
# squash = meld into previous commit (keeps both messages)
# fixup  = meld into previous commit (discards this message)
# drop   = remove this commit entirely
# edit   = pause here to amend the commit
```

### Common interactive rebase patterns

```bash
# Squash 3 messy WIP commits into one clean commit
# Change the file to:
pick abc1234 add login form
fixup def5678 fix typo
fixup ghi9012 fix another typo
# Result: one commit with message "add login form"

# Reword a commit message
reword abc1234 add login form
# Git will pause and open editor for new message

# Drop a commit entirely
drop def5678 fix typo

# Reorder commits (just move the lines)
pick ghi9012 fix another typo
pick abc1234 add login form
```

### Squash vs fixup

| Command | Keeps commit message? |
|---|---|
| `squash` | Yes — combines all messages, opens editor |
| `fixup` | No — silently discards this message, keeps previous |

> Use fixup for minor corrections (typos, formatting).
> Use squash when you want to write a combined message.

---

## 3. Rebase vs merge — full comparison

```
Merge result:
A ── B ── C ──────────── M   ← merge commit
           └── D ── E ──┘

Rebase result:
A ── B ── C ── D' ── E'      ← straight line, no merge commit
```

### When to use each

| Situation | Use |
|---|---|
| Keeping feature branch current with main | Rebase |
| Cleaning up commits before opening a PR | Interactive rebase |
| Merging a finished feature into main | Merge (preserves PR as a unit in history) |
| Shared branch others are working from | Merge only — never rebase |
| `git pull` on a team repo | `git pull --rebase` |

### Make rebase the default for pull

```bash
git config --global pull.rebase true
# Now plain "git pull" replays your commits on top instead of merge
```

---

## 4. The golden rule

> Never rebase a branch that other people are working from.

Rebase rewrites commit hashes. If a colleague pulled your branch
before you rebased it, their git history and yours are now incompatible.
Pushing a rebased branch to a remote that others have pulled requires
`git push --force` — which overwrites their work.

```
Safe to rebase:   your own feature branch, not yet pushed
                  your own feature branch, pushed but no one else has pulled it

Never rebase:     main, develop, or any branch shared with the team
```

---

## 5. Force push — when you must push a rebased branch

If you've already pushed a branch and then rebase it locally, the
remote and local histories have diverged. A normal push will be rejected.

```bash
git push --force-with-lease origin feature/my-branch
```

`--force-with-lease` is safer than `--force`:
- `--force` overwrites the remote unconditionally
- `--force-with-lease` refuses if someone else has pushed to the branch
  since you last fetched — protecting against overwriting teammates' work

> Only force push your own feature branches.
> Never force push main or any shared branch.

---

## Quick reference

```bash
# Standard rebase onto main
git fetch origin
git rebase origin/main

# Interactive rebase — clean up last N commits
git rebase -i HEAD~N

# Conflict resolution during rebase
git add resolved-file
git rebase --continue
git rebase --abort          # give up, restore original state

# Force push a rebased branch safely
git push --force-with-lease origin feature/my-branch
```
