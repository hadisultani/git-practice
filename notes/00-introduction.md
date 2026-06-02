# 00 — Introduction

## What is version control?

Version control is a system that records every change you make to a set of files
over time. It lets you look at any previous version of your work, see exactly what
changed and who changed it, and roll back to an earlier state if something goes wrong.

Without version control, you end up with this:

```
project/
├── report.docx
├── report_final.docx
├── report_final_v2.docx
├── report_final_v2_ACTUALLY_FINAL.docx
└── report_USE_THIS_ONE.docx
```

Version control solves this. You have one file. The system tracks its entire history.

---

## What is git?

Git is the version control system used by virtually every software team in the world.
It was created by Linus Torvalds in 2005 to manage the Linux kernel source code.

Key properties of git:

- **Distributed** — every developer has a full copy of the entire project history on their machine. There is no single point of failure.
- **Fast** — almost every operation is local, so there's no waiting for a server.
- **Reliable** — every file and commit is checksummed with a SHA-1 hash. Corruption is detected automatically.
- **Branching is cheap** — creating a branch is nearly instant and costs almost no storage.

Git tracks changes at the file level. Every time you commit, git takes a snapshot
of all your tracked files and stores a reference to that snapshot.

---

## Git vs GitHub

These are two different things that are often confused.

| | What it is |
|---|---|
| **Git** | The version control tool — runs on your machine, tracks changes, manages history |
| **GitHub** | A website that hosts git repositories — adds a web interface, pull requests, issues, Actions, and team collaboration features |

```
git     = the tool (installed on your computer)
GitHub  = the hosting service (github.com)
```

Other hosting services exist (GitLab, Bitbucket, Azure DevOps) but GitHub is the
most widely used, especially for open-source projects.

You can use git without GitHub — entirely local, on your own machine.
You can also use GitHub without understanding git deeply — but you'll hit walls fast.

---

## Installing git

### macOS

The easiest way is via Homebrew. Homebrew's git stays up to date; macOS's built-in
git is often years behind.

```bash
# Install Homebrew first if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install git
brew install git

# Verify
git --version
# git version 2.53.0
```

### Windows

Download **Git for Windows** from git-scm.com. It installs git plus Git Bash
(a terminal emulator that gives you a Unix-like shell on Windows).

During installation, the defaults are fine. Key choices:
- Default editor: choose VS Code if you have it
- Line ending conversion: "Checkout Windows-style, commit Unix-style" (the default)

```bash
# After installation, verify in Git Bash or PowerShell
git --version
```

### Linux (Debian / Ubuntu)

```bash
sudo apt update
sudo apt install git
git --version
```

### Linux (Fedora / RHEL)

```bash
sudo dnf install git
git --version
```

---

## Your first-time setup

After installing git, do these once before anything else.
Git uses this information to stamp every commit you make.

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

See [01-setup.md](01-setup.md) for the full setup guide including editor config,
useful defaults, and aliases.

---

## How this book is structured

```
00  Introduction        ← you are here
01  Setup              ← git config, aliases, global settings
02  Basics             ← clone, staging, commit, push
03  Fetch & Pull       ← staying in sync with a remote
04  Branching          ← branches, strategies, naming
05  Undoing            ← amend, reset, revert, stash
06  Rebase             ← rebase, interactive rebase, force push
07  Pull Requests      ← PR workflow, merge strategies, GitHub CLI
08  GitHub Actions     ← CI/CD, workflows, secrets
09  Security           ← 2FA, branch protection, secret scanning
10  .gitignore         ← ignoring files
11  Merge Conflicts    ← resolving conflicts
12  Reflog             ← recovering lost work
13  History Tools      ← log, blame, bisect
14  Tags               ← versioning and releases
15  Cherry Pick        ← picking individual commits
16  Conventional Commits ← commit message format
```

The chapters are ordered from first-day fundamentals to tools you'll reach for
as you grow more confident. Chapters 00–05 are essentials. Chapters 06–09 are
important once you're working in a team. Chapters 10–16 are the tools that make
you significantly faster and safer.
