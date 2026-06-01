# Git Practice

Personal git learning journal — commands, concepts, and notes built up through hands-on practice.

## Repository structure

```
git-practice/
├── README.md                   ← overview + index of all topics
├── notes/
│   ├── 01-setup.md             ← git config, .gitconfig, LFS
│   ├── 02-basics.md            ← clone, staging, commit, push
│   ├── 03-fetch-pull-rebase.md ← fetch vs pull, remote-tracking, rebase
│   ├── 04-branching.md         ← checkout, switch, restore, branch strategies
│   ├── 05-undoing.md           ← amend, reset, revert, stash
│   ├── 06-rebase.md            ← rebase concept + practice
│   ├── 07-pull-requests.md     ← PR workflow, squash merge, branch protection, auto-merge
│   └── 08-github-actions.md    ← (coming up)
│   └── 09-security.md          ← 2FA, branch protection, secret scanning, SSH
└── practice/
    └── sandbox.md              ← scratch file for trying things out
```

## Notes index

| File | Topics covered |
|---|---|
| [01-setup.md](notes/01-setup.md) | Git config, .gitconfig, push.default, Git LFS, global gitignore |
| [02-basics.md](notes/02-basics.md) | Clone, three zones, staging, commit, amend, push |
| [03-fetch-pull-rebase.md](notes/03-fetch-pull-rebase.md) | Fetch vs pull, remote-tracking branch, rebase vs merge |
| [04-branching.md](notes/04-branching.md) | Checkout, switch, restore, tracking, delete, branch strategies |
| [05-undoing.md](notes/05-undoing.md) | Amend, reset soft/mixed/hard, revert, stash |
| [06-rebase.md](notes/06-rebase.md) | Basic rebase, interactive rebase, force push safely |
| [07-pull-requests.md](notes/07-pull-requests.md) | PR workflow, merge strategies, branch protection, GitHub CLI |
| [08-github-actions.md](notes/08-github-actions.md) | *(coming up)* |
| [09-security.md](notes/09-security.md) | 2FA, branch protection, secret scanning, SSH, signed commits |

## Environment

- Git 2.53.0 · macOS · VS Code · GitHub Desktop