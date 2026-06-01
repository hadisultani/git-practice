# 01 — Setup

## Git version & tools
- Git version: 2.53.0
- Editor: VS Code
- Repo created via GitHub Desktop, published through VS Code

## One-time global configuration

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global core.editor "code --wait"
git config --global push.default simple

# Verify everything saved
cat ~/.gitconfig

# Remove a setting
git config --global --unset KEY
```

## ~/.gitconfig structure

```ini
[user]
    name = Your Name
    email = you@example.com
[core]
    editor = code --wait
[push]
    default = simple
[pull]
    rebase = true
[fetch]
    prune = true
[filter "lfs"]
    clean = git-lfs clean -- %f
    smudge = git-lfs smudge -- %f
    process = git-lfs filter-process
    required = true
```

> Common sections: [user], [core], [push], [pull], [filter]
> Edit directly with `cat ~/.gitconfig` or via `git config --global`

## push.default values

| Value | Behaviour |
|---|---|
| `simple` | Pushes current branch to matching upstream — refuses if names differ (default, safest) |
| `current` | Pushes to same-named branch on remote |
| `upstream` | Pushes to configured upstream even if names differ |
| `matching` | Pushes all local branches that have a matching remote — can be surprising |

## Auto-prune stale remote branches

After a PR is merged and the remote branch is deleted on GitHub, your
local machine still lists it under `git branch -a` as a stale ref.
`git fetch --prune` cleans those up automatically.

```bash
# One-off cleanup
git fetch --prune

# Set it globally so every fetch prunes automatically
git config --global fetch.prune true
```

Add to `~/.gitconfig`:

```ini
[fetch]
    prune = true
```

> Without this, `git branch -a` gradually fills up with dead remote refs
> from merged/deleted branches. At work with hundreds of developers
> this gets noisy fast.

---

## Git LFS (Large File Storage)

Installed automatically by GitHub Desktop. Handles large binary files
(videos, ML models, design assets) by storing a small pointer in the
repo and the real file on a separate LFS server.

```
Without LFS:  repo contains → actual 500MB file
With LFS:     repo contains → tiny pointer (~130 bytes)
              LFS server   → actual 500MB file
```

- `clean` filter — replaces real file with pointer on `git add`
- `smudge` filter — replaces pointer with real file on `git checkout`
- `required = true` — git errors rather than silently commit the real file

> Only relevant when a repo tracks binary/large files. Not needed for code-only repos.

---

## Git aliases

Shortcuts stored in `~/.gitconfig` that save keystrokes and encode good habits.

```bash
# Add aliases
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.sw switch
git config --global alias.br "branch -vv"
git config --global alias.lg "log --oneline --graph --decorate --all"
git config --global alias.undo "reset --mixed HEAD~1"
git config --global alias.unstage "restore --staged"
git config --global alias.aliases "config --global --list"

# The new branch alias — always branches from fresh main
# Use at the START of new work, after a PR is merged
git config --global alias.nb '!git checkout main && git pull && git checkout -b'

# View all aliases
git aliases

# Edit .gitconfig directly
code ~/.gitconfig
```

### nb alias — correct timing

```
PR merged → git pull (main updated) → git nb feature/next-task → do work → PR → repeat
```

> Never use git nb from inside another feature branch.
> Always signals the start of a fresh piece of work from latest main.
