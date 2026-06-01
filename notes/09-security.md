# 09 — Security & Safety

## Priority overview

| Priority | Setting | Where |
|---|---|---|
| 🔴 Must | Two-factor authentication | Account → Password and authentication |
| 🔴 Must | Block force pushes + deletions on main | Branch protection rules |
| 🔴 Must | Secret scanning + push protection | Security & analysis |
| 🟡 Should | Dependabot alerts | Security & analysis |
| 🟡 Should | Require linear history | Branch protection rules |
| 🟡 Should | Disable unused features | General settings |
| 🟡 Should | Interaction limits | Moderation |
| 🟢 Nice | SSH keys instead of HTTPS | Account → SSH and GPG keys |
| 🟢 Nice | Signed commits | git config |

---

## 1. Two-factor authentication (2FA)

The single most impactful setting. If someone gets into your GitHub
account they can change all repo settings and bypass everything else.

**github.com → Settings → Password and authentication**

```
✅ Enable two-factor authentication
   → use an authenticator app (not SMS — SIM swapping is a real attack)
   → save recovery codes somewhere safe (password manager or printed)
```

---

## 2. Branch protection rules

**Repo → Settings → Branches → Add rule → branch name pattern: `main`**

### Recommended settings for a public personal repo

```
✅ Require a pull request before merging
   ☐ Require approvals                     ← off for solo repos
   ☐ Dismiss stale reviews                 ← off (no approvals needed)
   ☐ Require review from Code Owners       ← off
   ☐ Require approval of most recent push  ← off

✅ Require status checks to pass before merging
   ✅ Require branches to be up to date    ← on
   (add CI check name here after setting up GitHub Actions)

☐ Require conversation resolution          ← optional
☐ Require signed commits                   ← optional
✅ Require linear history                   ← on — enforces squash/rebase only,
                                               no merge commits on main
☐ Lock branch                              ← off (would block your own PRs)
☐ Do not allow bypassing                   ← greyed out on free plan

── Rules applied to everyone including administrators ──
☐ Allow force pushes                       ← leave unchecked = force pushes BLOCKED
☐ Allow deletions                          ← leave unchecked = branch deletion BLOCKED
```

### Why the last two matter

**Allow force pushes — unchecked** means nobody can rewrite main history with:
```bash
git push --force origin main    # rejected by GitHub
```

**Allow deletions — unchecked** means nobody can wipe main with:
```bash
git push origin --delete main   # rejected by GitHub
```

### Require linear history

Enforces that only squash merges or rebase merges are allowed on main.
No merge commits. Keeps history clean and readable.
Consistent with the squash merge PR workflow.

---

## 3. Secret scanning and push protection

**Repo → Settings → Security & analysis**

```
✅ Dependency graph
✅ Dependabot alerts           ← warns if a dependency has a known vulnerability
✅ Dependabot security updates ← auto PRs to fix vulnerable dependencies
✅ Secret scanning             ← alerts if you accidentally commit a secret
✅ Push protection             ← BLOCKS pushes containing secrets before they land
```

**Push protection is critical.** Once a secret (API key, password, token)
hits GitHub it must be treated as compromised — even if you delete it
immediately, it stays in git history and may have been scraped already.

Push protection stops the commit before it ever reaches GitHub:

```bash
git push origin feature/my-branch
# remote: error: GH013: Repository rule violations found for refs/heads/...
# remote: — Secret detected: GitHub Personal Access Token
# Push rejected.
```

---

## 4. Disable unused features

**Repo → Settings → General → Features**

Turn off anything you're not actively using — each enabled feature is
a potential surface for spam or abuse.

```
☐ Wikis          ← off unless actively used
☐ Projects       ← off unless actively used
☐ Discussions    ← off unless you want public Q&A
✅ Issues         ← keep on — useful for tracking work
```

**Repo → Settings → General → Pull Requests**

```
✅ Automatically delete head branches    ← clean up after every merge
✅ Allow squash merging                  ← your chosen strategy
☐ Allow merge commits                   ← off — enforces linear history
☐ Allow rebase merging                  ← optional
```

---

## 5. Interaction limits

**Repo → Settings → Moderation → Interaction limits**

Prevents drive-by spam on issues and PRs from brand new throwaway accounts.

```
Limit interactions to: existing GitHub users
Duration: 6 months
```

---

## 6. SSH keys (instead of HTTPS)

More secure than HTTPS with a password. Uses public/private key cryptography.

```bash
# Generate an SSH key (ed25519 is the modern standard)
ssh-keygen -t ed25519 -C "you@example.com"
# saves to ~/.ssh/id_ed25519 (private) and ~/.ssh/id_ed25519.pub (public)

# Copy the public key
cat ~/.ssh/id_ed25519.pub

# Add to GitHub: Settings → SSH and GPG keys → New SSH key
# Paste the output of the above command

# Test the connection
ssh -T git@github.com
# Hi USERNAME! You've successfully authenticated.

# Update your remote to use SSH instead of HTTPS
git remote set-url origin git@github.com:USERNAME/git-practice.git

# Verify
git remote -v
```

> Never share or commit your private key (~/.ssh/id_ed25519).
> The public key (~/.ssh/id_ed25519.pub) is safe to share — that's the point.

---

## 7. Signed commits (optional)

Proves commits actually came from you — GitHub shows a "Verified" badge.
Uses GPG to cryptographically sign each commit.

```bash
# Generate a GPG key
gpg --full-generate-key
# Choose: RSA, 4096 bits, your GitHub email

# Get your key ID
gpg --list-secret-keys --keyid-format=long

# Export your public key (add to GitHub: Settings → SSH and GPG keys → New GPG key)
gpg --armor --export YOUR_KEY_ID

# Tell git to sign commits
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true
```

---

## 8. What to do if a secret is accidentally committed

If you accidentally commit an API key, password, or token:

```bash
# 1. Revoke the secret IMMEDIATELY — assume it is already compromised
#    Go to wherever the key was issued and invalidate it

# 2. Remove it from history using git filter-repo (modern tool)
pip install git-filter-repo
git filter-repo --path secrets.txt --invert-paths   # remove a file entirely
git filter-repo --replace-text expressions.txt      # replace specific strings

# 3. Force push the cleaned history
git push --force origin main

# 4. Notify anyone who may have cloned the repo
```

> Deleting the file in a new commit is NOT enough — the secret
> is still visible in git history. You must rewrite history and
> treat the secret as compromised regardless.

---

## Quick checklist for a new public repo

```
□ 2FA enabled on your GitHub account
□ Branch protection rule on main:
    □ Require PR before merging
    □ Require linear history
    □ Force pushes blocked (Allow force pushes unchecked)
    □ Deletions blocked (Allow deletions unchecked)
□ Secret scanning + push protection enabled
□ Dependabot alerts enabled
□ Unused features disabled (Wikis, Projects, Discussions)
□ Interaction limits set
□ SSH keys configured (optional but recommended)
```
