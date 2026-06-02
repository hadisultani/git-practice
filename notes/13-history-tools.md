# 13 — History Tools

## Overview

Three tools for understanding a repository's history:

| Tool | Question it answers |
|---|---|
| `git log` | What changed, when, and by whom — across the whole project |
| `git blame` | Who wrote each line of a specific file, and in which commit |
| `git bisect` | Which commit first introduced a bug |

---

## 1. git log — in depth

### Basic formats

```bash
git log                              # full log — message, author, date, hash
git log --oneline                    # one line per commit — hash + message
git log --oneline --graph --all      # visual branch/merge graph
git log --oneline --decorate         # shows branch and tag labels on commits
git log --stat                       # adds files changed + lines added/removed
git log --patch                      # adds full diff for every commit (very verbose)
git log -p -3                        # full diff for the last 3 commits only
```

### Filtering by author

```bash
git log --author="Hadi"             # partial match — case sensitive
git log --author="hadi@example.com" # match by email
git log --author="Hadi\|Alice"      # multiple authors (regex)
```

### Filtering by date

```bash
git log --since="2024-01-01"
git log --until="2024-06-30"
git log --since="2 weeks ago"
git log --since="yesterday"
git log --after="2024-01-01" --before="2024-06-30"
```

### Filtering by commit message

```bash
git log --grep="login"              # commits whose message contains "login"
git log --grep="fix" --grep="auth"  # contains "fix" OR "auth"
git log --grep="fix" --all-match    # contains BOTH "fix" AND "auth" (when combined)
git log --grep="feat:" --oneline    # find all feature commits (conventional style)
```

### Filtering by content — the pickaxe

```bash
# Find commits that added or removed a specific string
git log -S "getUserById"            # commits where this string was added or removed
git log -S "API_KEY"                # find when a secret was introduced or removed
git log -G "getUserBy.*"            # same but accepts a regex pattern
```

The `-S` flag (called the "pickaxe") is extremely useful for finding when a
function was introduced, renamed, or deleted.

### Filtering by file

```bash
git log -- filename.md              # commits that touched this file
git log -- src/auth/               # commits that touched anything in this directory
git log --follow -- old-name.md    # follow a file through renames
```

`--follow` is essential when a file has been renamed — without it, `git log`
stops at the rename point.

### Custom output format

```bash
git log --format="%h %an %ar %s"
# abc1234 Hadi Sultani 2 days ago feat: add login form

# Format codes:
# %h  = short commit hash
# %H  = full commit hash
# %an = author name
# %ae = author email
# %ar = relative date ("2 days ago")
# %ad = absolute date
# %s  = subject (first line of commit message)
# %b  = body (everything after the first line)

# Pretty presets
git log --pretty=short
git log --pretty=full
git log --pretty=fuller
```

### Combining filters

```bash
# All commits by Hadi in the last month that touched the auth directory
git log --author="Hadi" --since="1 month ago" -- src/auth/

# All feature commits on main since v1.0.0
git log --oneline --grep="^feat:" main...v1.0.0
```

---

## 2. git blame — who wrote each line

`git blame` annotates every line of a file with the commit hash, author,
and date that last modified it.

```bash
git blame filename.md
```

Output:

```
abc1234 (Hadi Sultani  2024-03-01 14:22:08 +0000  1) # My File
def5678 (Alice Smith   2024-04-15 09:11:00 +0000  2) Some content here
abc1234 (Hadi Sultani  2024-03-01 14:22:08 +0000  3) More content
```

### Useful blame options

```bash
# Show only the last N lines
git blame -L 10,25 filename.md         # lines 10 to 25
git blame -L 10,+15 filename.md        # 15 lines starting from line 10

# Show the commit that originally wrote the line, ignoring later moves
git blame -C filename.md               # detect lines moved within the same file
git blame -C -C filename.md            # also detect copies from other files

# Ignore whitespace-only changes
git blame -w filename.md

# Show the full commit hash instead of abbreviated
git blame --abbrev=40 filename.md
```

### From the blame, inspect the full commit

```bash
# Get the commit details for any hash shown by blame
git show abc1234

# See all files changed in that commit
git show abc1234 --stat
```

### VS Code integration

In VS Code, install **GitLens** — it shows blame information inline on every
line as you edit, and lets you click through to the full commit.

---

## 3. git bisect — find the commit that broke something

`git bisect` does a binary search through commit history to find the exact
commit that introduced a bug. Instead of checking commits one by one,
it halves the search space each step — finding the bad commit in O(log n) steps.

```
500 commits to search → git bisect finds the culprit in ~9 steps
```

### Basic bisect workflow

```bash
# 1. Start bisecting
git bisect start

# 2. Mark the current commit as bad (the bug exists here)
git bisect bad

# 3. Mark a known good commit (before the bug existed)
git bisect good v1.0.0          # a tag
git bisect good abc1234         # a specific commit
git bisect good HEAD~50         # 50 commits ago

# Git checks out a commit halfway between good and bad.
# Test whether the bug exists in this version, then mark it:

git bisect good    # bug does NOT exist in this commit
git bisect bad     # bug DOES exist in this commit

# Git keeps halving. Repeat until git prints:
# "abc1234 is the first bad commit"

# 4. When done, return to your branch
git bisect reset
```

### Automated bisect — let a script do the testing

If you can write a script that exits with 0 (good) or non-zero (bad):

```bash
git bisect start
git bisect bad HEAD
git bisect good v1.0.0

# Run the script automatically against each commit git checks out
git bisect run npm test                       # runs your test suite
git bisect run ./scripts/check-login.sh       # runs a custom check script

# Git finds the first bad commit automatically and prints it
git bisect reset
```

### After finding the bad commit

```bash
# Inspect the commit that introduced the bug
git show abc1234

# See what changed
git show abc1234 --stat
git show abc1234 -p

# Who made the change
git log --format="%an %ae" abc1234 -1
```

---

## Quick reference

```bash
# Log — common combos
git log --oneline --graph --all
git log --author="Name" --since="2 weeks ago"
git log --grep="feat:"
git log -S "functionName"              # find when a string appeared/disappeared
git log --follow -- old-filename.md   # follow through renames
git log -- path/to/file               # commits touching a specific file

# Blame
git blame filename.md
git blame -L 10,25 filename.md        # specific line range

# Bisect
git bisect start
git bisect bad
git bisect good <known-good-ref>
git bisect good    # or: git bisect bad   (after testing each step)
git bisect run <test-script>
git bisect reset
```
