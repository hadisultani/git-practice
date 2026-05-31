# Git Practice Notes

## Environment
- Git version: 2.53.0
- Editor: VS Code (`core.editor = code --wait`)
- Repo created via GitHub Desktop, published through VS Code

---

## 1. One-time global setup

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global core.editor "code --wait"
git config --global push.default simple

# Verify everything
cat ~/.gitconfig
```

---

## 2. Create a repo & clone

- Created on GitHub with README and .gitignore initialized
- Initializing with a README creates the first commit and default branch automatically
- Cloned locally — git automatically sets up `origin` as an alias for the GitHub URL

```bash
git clone https://github.com/USERNAME/REPO.git
cd REPO

git remote -v          # confirm origin points to GitHub
git branch -a          # see local + remote-tracking branches
git log --oneline      # see initial commit
```

---

## 3. The three zones

- `git status` always tells you which zone your changes are in
- Changes must be staged before they can be committed

---

## 4. Basic commit workflow

```bash
git status                   # see what changed
git add filename             # stage a specific file
git add .                    # stage everything
git diff --staged            # preview what will go into the commit
git commit -m "your message"
git log --oneline            # confirm commit was created
git push                     # send commits to GitHub
```

---

## 5. Amending commits (before pushing only)

Use when you want to fix or add to the last commit without creating a new one.

```bash
# Add a forgotten change to the last commit
git add filename
git commit --amend --no-edit     # keeps same commit message

# Also rewrite the commit message
git commit --amend               # opens VS Code to edit message
```

> ⚠️ Never amend after pushing — it rewrites the commit hash.
> Anyone who pulled the old hash will have a different history than you.

---

## 6. One commit vs two commits

| Situation | Approach |
|---|---|
| Small fix or forgotten file — same idea as last commit | `--amend` |
| Different/new change that deserves its own history entry | New commit |
| Already pushed | New commit always |

---

## 7. git push variants

```bash
git push                           # push current branch to its tracked upstream
git push origin main               # explicit — always unambiguous
git push -u origin my-branch       # first push of a new branch, sets tracking
                                   # plain "git push" works from this branch after
```

`push.default` controls what plain `git push` does. Default in git 2.0+ is `simple`:
- Pushes current branch to matching upstream
- Refuses if remote branch name differs — safe behavior

---

## 8. ~/.gitconfig

Global git preferences stored at `~/.gitconfig`. Edit directly or via:

```bash
git config --global KEY value
git config --global --list         # see everything
git config --global --unset KEY    # remove a setting
```

Common sections: `[user]`, `[core]`, `[push]`, `[filter]`

---

## 9. Git LFS (Large File Storage)

Installed automatically by GitHub Desktop. Handles large binary files
(videos, models, assets) by storing a small pointer in the repo and
the real file on a separate LFS server.

- `clean` filter — replaces real file with pointer on `git add`
- `smudge` filter — replaces pointer with real file on `git checkout`
- Only relevant when a repo tracks binary/large files

Not needed for code-only repos.