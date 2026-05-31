# 07 — Pull Requests

## What a pull request is

A pull request (PR) is a proposal to merge one branch into another.
It is not a git concept — it is a GitHub feature built on top of git.
The underlying git operation is just a merge, but GitHub wraps it with
a review interface, discussion thread, status checks, and an audit trail.

```
feature/my-feature  ──── PR ────►  main
                     (review,
                      discuss,
                      approve,
                      merge)
```

At work with hundreds of developers, PRs are the primary way code gets
reviewed, discussed, and safely integrated. Understanding them deeply
matters more than almost any other git skill.

---

## 1. The PR workflow end to end

```bash
# 1. Create a feature branch
git checkout -b feature/my-feature

# 2. Do your work — one or more commits
git add .
git commit -m "feat: add my feature"

# 3. Push the branch to GitHub
git push -u origin feature/my-feature

# 4. Open the PR — from command line (recommended) or browser
gh pr create --title "feat: my feature" --body "Description here"

# 5. Address review feedback — push more commits to the same branch
git add .
git commit -m "fix: address review comments"
git push          # updates the open PR automatically

# 6. PR gets approved and merged

# 7. Clean up locally
git checkout main
git pull                                        # get the merged changes
git branch -d feature/my-feature               # delete local branch
git push origin --delete feature/my-feature    # delete remote branch
```

---

## 2. Creating a PR from the command line

GitHub CLI (`gh`) lets you create and manage PRs without leaving the terminal.

### Install and authenticate

```bash
# Install on macOS
brew install gh

# Authenticate with your GitHub account
gh auth login
# Follow the prompts — choose GitHub.com, HTTPS, authenticate via browser
```

### Create a PR

```bash
# Basic — opens your editor to write title and body interactively
gh pr create

# Inline title and body
gh pr create --title "feat: my feature" --body "Description here"

# Using the repo's PR template as your body (recommended)
gh pr create --title "feat: my feature" --body-file .github/pull_request_template.md

# Open the PR in browser after creating
gh pr create --title "feat: my feature" --body "Description" --web

# Create as draft
gh pr create --draft --title "feat: my feature" --body "Work in progress"

# Target a specific base branch (default is main)
gh pr create --base develop --title "feat: my feature" --body "Description"

# Set reviewers, labels and assignee in one go
gh pr create \
  --title "feat: my feature" \
  --body "Description" \
  --reviewer teammate1,teammate2 \
  --label "enhancement" \
  --assignee "@me"
```

### Manage existing PRs

```bash
gh pr list                        # list all open PRs
gh pr list --author "@me"         # your PRs only
gh pr list --label "bug"          # filter by label
gh pr view 42                     # view PR #42 in terminal
gh pr view 42 --web               # open PR #42 in browser
gh pr checkout 42                 # check out PR branch locally
gh pr status                      # show PRs relevant to you
gh pr close 42                    # close without merging
gh pr reopen 42                   # reopen a closed PR
```

---

## 3. Squash and merge — deep dive

Squash and merge takes all the commits on your feature branch and
collapses them into a single new commit on main.

### What it looks like

```
Feature branch commits:
  abc1111  feat: add login form scaffold
  abc2222  fix: typo in label
  abc3333  fix: handle empty email
  abc4444  fix: address review feedback

After squash and merge onto main:
  def9999  feat: add login form  ← one clean commit, all changes combined
```

### Why use it

- Feature branches often have noisy WIP commits ("fix", "try this", "ugh")
- Keeps `main` history clean — one commit per feature/bugfix
- Each commit on main maps directly to one PR — easy to trace and revert
- If the feature turns out to be wrong, one `git revert` undoes all of it

### How to squash merge from the command line

```bash
# Squash merge locally (without GitHub PR)
git checkout main
git merge --squash feature/my-feature
git commit -m "feat: add login form"    # write the final clean message

# Via GitHub CLI
gh pr merge 42 --squash
gh pr merge 42 --squash --subject "feat: add login form"   # custom message
gh pr merge 42 --squash --delete-branch                    # also delete branch
```

### Squash merge commit message convention

When squashing, GitHub auto-generates a message combining all commits.
It's good practice to rewrite it to a single clean conventional commit:

```
feat: add login form

- Validates email format
- Handles empty fields gracefully
- Closes #42
```

### When NOT to squash

| Situation | Use instead |
|---|---|
| Each commit is meaningful and well-written | Rebase and merge |
| You want a clear marker of when a feature landed | Merge commit |
| The branch is long-lived and shared | Merge commit |
| You need to bisect individual commits later | Rebase and merge |

---

## 4. Making reviews and approvals mandatory

Branch protection rules enforce that PRs must be reviewed before merging.
Set them up under: **GitHub repo → Settings → Branches → Add branch protection rule**

### Recommended settings for main

| Setting | Value | Why |
|---|---|---|
| Branch name pattern | `main` | Protects the main branch |
| Require a pull request before merging | ✅ On | No direct pushes to main |
| Required number of approvals | 1 (personal) / 2+ (team) | At least one reviewer must approve |
| Dismiss stale reviews when new commits are pushed | ✅ On | New commits re-require approval |
| Require review from code owners | Optional | Enforces domain experts review relevant files |
| Require status checks to pass | ✅ On (when CI is set up) | CI must be green before merge |
| Require branches to be up to date | ✅ On | Branch must be current with main |
| Do not allow bypassing the above settings | ✅ On | Even admins must follow the rules |

### Setting up via GitHub CLI

```bash
# Require 1 approval and up-to-date branch on main
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --field required_pull_request_reviews[required_approving_review_count]=1 \
  --field required_pull_request_reviews[dismiss_stale_reviews]=true \
  --field enforce_admins=true
```

---

## 5. Auto-merge — merge automatically when approved

Auto-merge lets a PR merge itself the moment all required conditions
are satisfied (approvals, CI checks, up-to-date branch) — without
anyone having to click the merge button.

### Enable auto-merge on the repo (one-time)

**GitHub repo → Settings → General → Pull Requests → Allow auto-merge ✅**

### Enable auto-merge on a specific PR

```bash
# Via GitHub CLI — set the merge strategy when enabling
gh pr merge 42 --auto --squash       # squash when conditions met
gh pr merge 42 --auto --merge        # merge commit when conditions met
gh pr merge 42 --auto --rebase       # rebase when conditions met

# Cancel auto-merge if you change your mind
gh pr merge 42 --disable-auto
```

### Via browser

On the PR page, after creating it you'll see:
**"Enable auto-merge"** → choose squash / merge / rebase → confirm

The PR page then shows a banner:
> Auto-merge enabled — will squash and merge when all requirements are met

### How it behaves in practice

```
PR opened
    │
    ├── CI runs → must pass
    ├── Reviewer approves → required approval satisfied  
    ├── Branch up to date with main → satisfied
    │
    └── All conditions met → GitHub auto-squashes and merges
                          → branch deleted (if configured)
                          → you get a notification
```

### Manual vs auto-merge — when to use each

| | Manual merge | Auto-merge |
|---|---|---|
| Control over exact merge timing | Full control | GitHub decides when ready |
| Best for | PRs needing careful coordination | Routine features and fixes |
| Works well with | Complex changes, release timing | CI-gated, well-tested repos |
| Risk | Human forgets to merge | Merges before you're truly ready |

> Tip: enable auto-merge immediately after opening a PR so it
> merges as soon as your reviewer approves. You can always cancel it.

---

## 6. PR best practices

### Writing a good PR description

A good description answers three questions:
- What changed?
- Why was this change needed?
- How was it tested?

```markdown
## What
Brief description of what this PR does.

## Why
Context — the problem being solved or the feature being added.
Closes #42

## Testing
How you verified this works.

## Notes for reviewer
Anything you want the reviewer to pay particular attention to.
```

### Reviewing a PR

```bash
# Check out the PR branch locally to test it
git fetch origin
git checkout feature/my-feature

# Or using GitHub CLI
gh pr checkout 42
```

Review comment types:
- **Comment** — general feedback, no approval implied
- **Approve** — LGTM, ready to merge
- **Request changes** — must be addressed before merging

### Draft PRs

Open as draft when work isn't ready to merge but you want early feedback.
Draft PRs cannot be merged until marked ready. Still triggers CI.

```bash
gh pr create --draft --title "feat: my feature" --body "Work in progress"
```

---

## 7. Merge strategies comparison

| Strategy | History | Best for |
|---|---|---|
| Merge commit | Preserves full branch history, adds merge commit | Long-lived features, clear landing marker |
| Squash and merge | One commit per PR on main, clean history | Noisy branches, small changes, bug fixes |
| Rebase and merge | Linear history, individual commits preserved | Clean branches with meaningful commits |

---

## Quick reference

```bash
# Install GitHub CLI
brew install gh && gh auth login

# Full PR workflow from terminal
git checkout -b feature/my-feature
git add . && git commit -m "feat: description"
git push -u origin feature/my-feature
gh pr create --title "feat: description" --body-file .github/pull_request_template.md

# Enable auto-merge with squash
gh pr merge --auto --squash

# After PR merges — clean up
git checkout main && git pull
git branch -d feature/my-feature
git push origin --delete feature/my-feature

# Useful PR commands
gh pr list
gh pr status
gh pr view 42 --web
gh pr checkout 42
gh pr merge 42 --squash --delete-branch
```
