# Git Practice

A practical git reference — from first-time setup to the tools regular users reach for daily. Structured as a small book, ordered from fundamentals to advanced topics.

## Repository structure

```
git-practice/
├── README.md                      ← overview + index of all topics
├── notes/
│   ├── 00-introduction.md         ← what is git, git vs GitHub, installing
│   ├── 01-setup.md                ← git config, .gitconfig, LFS, aliases, defaultBranch
│   ├── 02-basics.md               ← init, clone, staging, add -p, diff, commit, push
│   ├── 03-fetch-pull-rebase.md    ← fetch vs pull, remote-tracking, rebase
│   ├── 04-branching.md            ← checkout, switch, restore, branch strategies
│   ├── 05-undoing.md              ← amend, reset, revert, stash, restore, clean
│   ├── 06-rebase.md               ← rebase concept + practice
│   ├── 07-pull-requests.md        ← PR workflow, squash merge, branch protection, auto-merge
│   ├── 08-github-actions.md       ← workflows, triggers, secrets, matrix builds
│   ├── 09-security.md             ← 2FA, branch protection, secret scanning, SSH
│   ├── 10-gitignore.md            ← patterns, global ignore, templates
│   ├── 11-merge-conflicts.md      ← conflict markers, resolving, aborting
│   ├── 12-reflog.md               ← recovering lost commits and branches
│   ├── 13-history-tools.md        ← git log deep dive, blame, bisect
│   ├── 14-tags.md                 ← annotated tags, semantic versioning, releases
│   ├── 15-cherry-pick.md          ← picking individual commits across branches
│   └── 16-conventional-commits.md ← commit message format and tooling
└── practice/
    └── sandbox.md                 ← scratch file for trying things out
```

## Notes index

| File | Topics covered |
|---|---|
| [00-introduction.md](notes/00-introduction.md) | What is version control, git vs GitHub, installing git |
| [01-setup.md](notes/01-setup.md) | Git config, .gitconfig, push.default, defaultBranch, config --list, Git LFS, aliases |
| [02-basics.md](notes/02-basics.md) | git init, clone, three zones, staging, add -p, diff, commit, amend, push |
| [03-fetch-pull-rebase.md](notes/03-fetch-pull-rebase.md) | Fetch vs pull, remote-tracking branch, rebase vs merge |
| [04-branching.md](notes/04-branching.md) | Checkout, switch, restore, tracking, delete, branch strategies |
| [05-undoing.md](notes/05-undoing.md) | Amend, reset soft/mixed/hard, revert, stash, restore --source, clean |
| [06-rebase.md](notes/06-rebase.md) | Basic rebase, interactive rebase, force push safely |
| [07-pull-requests.md](notes/07-pull-requests.md) | PR workflow, merge strategies, branch protection, GitHub CLI, reviewing, updating |
| [08-github-actions.md](notes/08-github-actions.md) | Workflows, triggers, jobs, secrets, caching, matrix builds, branch protection integration |
| [09-security.md](notes/09-security.md) | 2FA, branch protection, secret scanning, SSH, signed commits |
| [10-gitignore.md](notes/10-gitignore.md) | Patterns, global gitignore, language templates, tracking fixes |
| [11-merge-conflicts.md](notes/11-merge-conflicts.md) | Conflict markers, resolving in VS Code, aborting, prevention |
| [12-reflog.md](notes/12-reflog.md) | Recovering from bad resets, deleted branches, bad rebases |
| [13-history-tools.md](notes/13-history-tools.md) | git log filters, git blame, git bisect |
| [14-tags.md](notes/14-tags.md) | Annotated vs lightweight, push tags, semantic versioning, GitHub releases |
| [15-cherry-pick.md](notes/15-cherry-pick.md) | Picking commits, ranges, conflicts, when to use |
| [16-conventional-commits.md](notes/16-conventional-commits.md) | Types, scopes, breaking changes, changelogs, enforcement |

## Environment

- Git 2.53.0 · macOS · VS Code · GitHub Desktop
