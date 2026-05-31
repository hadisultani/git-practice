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
