# 02 — Basics

## Creating a repo & cloning

- Create on GitHub with README and .gitignore initialized
- Initializing with a README creates the first commit and default branch automatically
- `origin` is just an alias for your GitHub URL — set up automatically on clone

```bash
git clone https://github.com/USERNAME/REPO.git
cd REPO

git remote -v          # confirm origin points to GitHub
git branch -a          # see local branch + remote-tracking branches
git log --oneline      # see initial commit
```

## The three zones

```
Working tree  ──git add──►  Staging area  ──git commit──►  Local repo  ──git push──►  GitHub
(your files)                  (index)                         (.git)                  (origin)
```

- `git status` always tells you which zone your changes are in
- Changes must be staged before they can be committed
- `git push` sends ALL unpushed local commits — not just the latest one

## Basic commit workflow

```bash
git status                      # see what changed and which zone it's in
git add filename                # stage a specific file
git add .                       # stage everything in current directory
git diff --staged               # preview exactly what will go into the commit
git commit -m "your message"    # commit with inline message
git log --oneline               # confirm commit was created
git log --oneline --graph --decorate  # visual commit graph
git show HEAD                   # full diff of last commit
git show HEAD --stat            # just the file summary
git push                        # send commits to GitHub
```

## Amending commits (before pushing only)

Use when you want to fix or add to the last commit without creating a new one.

```bash
# Add a forgotten change to the last commit
git add filename
git commit --amend --no-edit     # keeps same commit message

# Rewrite the commit message too
git commit --amend               # opens VS Code to edit message
```

> ⚠️ Never amend after pushing — it rewrites the commit hash.
> Anyone who pulled the old hash will have a different history than you.

## One commit vs two commits

| Situation | Approach |
|---|---|
| Small fix or forgotten file — same idea as last commit | `--amend` |
| Different change that deserves its own history entry | New commit |
| Already pushed | New commit always — never amend |

## git push variants

```bash
git push                              # push current branch to tracked upstream
git push origin main                  # explicit — always unambiguous
git push -u origin my-branch         # first push of a new branch — sets tracking
                                      # plain "git push" works from this branch after
```

> Use `-u` the first time you push a new branch.
> After that, plain `git push` is fine from that branch.
