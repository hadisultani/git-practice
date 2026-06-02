# 15 — Cherry Pick

## What cherry-pick does

`git cherry-pick` copies one or more commits from another branch and applies
them to the current branch as new commits. The original commits stay exactly
where they are — cherry-pick creates copies with new hashes.

```
Before:

main:    A ── B ── C
feature: A ── D ── E ── F

git cherry-pick E (from main branch)

After:

main:    A ── B ── C ── E'   ← E' is a copy of E, new hash
feature: A ── D ── E ── F    ← E is unchanged
```

---

## 1. When to use cherry-pick

| Situation | Example |
|---|---|
| A hotfix was committed to a feature branch by mistake — needs to go to main too | `git cherry-pick` the fix commit onto main |
| Back-port a bug fix to an older release branch | Pick the fix from main onto `release/v1.x` |
| You want one specific commit from a branch but not the whole branch | Pick just that commit |
| A colleague's work in progress has one commit you need right now | Pick just that commit |

### When NOT to use cherry-pick

- When you want all the work from a branch — use a regular merge or PR instead
- When the commits have complex dependencies on each other — cherry-picking middle commits without their context causes bugs
- On shared long-lived branches where teammates are working — communicate first

---

## 2. Picking a single commit

```bash
# Switch to the branch you want to apply the commit to
git switch main

# Pick a specific commit by its hash
git cherry-pick abc1234

# Verify it landed
git log --oneline
```

The hash shown in `git log` will be different from the original — same changes,
new commit object.

---

## 3. Picking a range of commits

```bash
# Pick commits from abc1234 up to and including def5678
# (oldest to newest, left to right)
git cherry-pick abc1234..def5678

# The above excludes abc1234 itself. To include it:
git cherry-pick abc1234^..def5678

# Pick multiple non-consecutive commits
git cherry-pick abc1234 def5678 ghi9012
```

---

## 4. Useful options

```bash
# Pick but don't commit yet — stage the changes for review first
git cherry-pick abc1234 --no-commit
git status          # see what was applied
git diff --staged   # review the changes
git commit          # commit when ready

# Edit the commit message when picking
git cherry-pick abc1234 --edit

# Preserve the original author (instead of using your own author info)
# Useful when porting commits written by a colleague
git cherry-pick abc1234 --no-commit
git commit --author="Original Author <author@example.com>"
```

---

## 5. Conflicts during cherry-pick

Cherry-pick can conflict if the code around the picked commit has changed
on the target branch.

```bash
git cherry-pick abc1234

# If a conflict occurs:
git status                   # see conflicting files
# ... resolve the markers in each file ...
git add resolved-file.md
git cherry-pick --continue   # finish applying the commit

# To skip this commit and move on (picking a range)
git cherry-pick --skip

# To give up and undo the cherry-pick entirely
git cherry-pick --abort
```

---

## 6. Finding the commit to pick

Before cherry-picking you need the commit hash. Common ways to find it:

```bash
# View commits on a branch you're not on
git log --oneline feature/my-branch

# Search by commit message
git log --oneline --all --grep="hotfix: payment crash"

# Search by code change (what string was introduced)
git log -S "fixPaymentFlow" --all --oneline

# View the commit details before picking
git show abc1234
git show abc1234 --stat
```

---

## Quick reference

```bash
# Pick a single commit
git cherry-pick abc1234

# Pick a range (inclusive of both ends)
git cherry-pick abc1234^..def5678

# Pick without committing (stage only)
git cherry-pick abc1234 --no-commit

# Conflict resolution
git add resolved-file
git cherry-pick --continue
git cherry-pick --abort

# Find the commit to pick
git log --oneline feature/branch-name
git log -S "search string" --all --oneline
```
