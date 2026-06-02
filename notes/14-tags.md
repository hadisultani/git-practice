# 14 — Tags

## What tags are

A tag is a named pointer to a specific commit — like a branch, but fixed.
Branches move forward as you commit; tags stay permanently attached to one commit.

Tags are used to mark release points: `v1.0.0`, `v2.3.1`, `v3.0.0-beta.1`.

```
main:  A ── B ── C ── D ── E ── F
                 ↑              ↑
               v1.0.0         v1.1.0
```

---

## 1. Two types of tags

### Lightweight tags

A simple pointer to a commit. No extra information.

```bash
git tag v1.0.0              # tags the current commit
git tag v1.0.0 abc1234      # tags a specific commit
```

### Annotated tags

A full git object with a message, author, and date. These are what you should
use for releases — they carry meaning and can be signed with GPG.

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git tag -a v1.0.0 abc1234 -m "Release version 1.0.0"   # tag a specific commit
```

### Which to use

| Type | When to use |
|---|---|
| Lightweight | Quick personal bookmarks, temporary pointers |
| Annotated | Every public release — use this by default |

---

## 2. Listing tags

```bash
git tag                     # list all tags alphabetically
git tag -l "v1.*"           # filter by pattern
git tag -l --sort=-v:refname   # sort by semantic version, newest first

# Show the annotated tag details
git show v1.0.0
```

---

## 3. Pushing tags to GitHub

Tags are not pushed with a normal `git push`. You must push them explicitly.

```bash
# Push a single tag
git push origin v1.0.0

# Push all local tags at once
git push origin --tags

# Push only annotated tags (recommended)
git push origin --follow-tags
```

> `--follow-tags` pushes only annotated tags that are reachable from the pushed
> commits. This is safer than `--tags`, which pushes everything including
> lightweight and potentially private tags.

---

## 4. Deleting tags

```bash
# Delete local tag
git tag -d v1.0.0

# Delete remote tag
git push origin --delete v1.0.0

# Delete multiple tags at once
git tag -d v1.0.0 v1.0.1 v1.0.2
```

---

## 5. Checking out a tag

To inspect the code at a specific release:

```bash
# View the code at a tag (detached HEAD state)
git checkout v1.0.0

# Better — create a branch from the tag if you need to make changes
git checkout -b hotfix/v1.0.1 v1.0.0
```

See [04-branching.md](04-branching.md) for more on detached HEAD state.

---

## 6. Semantic versioning

The standard format for release versions is `MAJOR.MINOR.PATCH`:

```
v2.4.1
│ │ └── PATCH — backwards-compatible bug fixes
│ └──── MINOR — backwards-compatible new features
└────── MAJOR — breaking changes that are not backwards-compatible
```

Pre-release versions:

```
v1.0.0-alpha.1      ← early unstable
v1.0.0-beta.2       ← feature complete, being tested
v1.0.0-rc.1         ← release candidate, near-final
v1.0.0              ← stable release
```

### Tag naming convention

```bash
# Always prefix with v
git tag -a v1.0.0 -m "Release v1.0.0"

# Pre-releases
git tag -a v2.0.0-beta.1 -m "Beta release for v2.0.0"
```

---

## 7. GitHub Releases

A GitHub Release is a GitHub UI concept built on top of git tags.
It packages a tag with release notes, a title, and optional binary assets
(compiled executables, packages, etc.).

```bash
# Create a GitHub release from the command line
gh release create v1.0.0 \
  --title "Version 1.0.0" \
  --notes "What changed in this release"

# Create a release from a specific tag
gh release create v1.0.0 --target main

# Create a pre-release
gh release create v2.0.0-beta.1 --prerelease

# Attach files to a release (e.g. compiled binaries)
gh release create v1.0.0 dist/myapp-linux dist/myapp-macos

# Auto-generate release notes from PR titles since last tag
gh release create v1.1.0 --generate-notes

# List releases
gh release list

# View a specific release
gh release view v1.0.0
```

---

## Quick reference

```bash
# Create an annotated tag (use for releases)
git tag -a v1.0.0 -m "Release v1.0.0"

# Tag a specific past commit
git tag -a v1.0.0 abc1234 -m "Release v1.0.0"

# List tags
git tag
git tag -l "v1.*"

# Push tags
git push origin v1.0.0               # single tag
git push origin --follow-tags        # all annotated tags

# Delete
git tag -d v1.0.0                    # local
git push origin --delete v1.0.0      # remote

# Inspect
git show v1.0.0

# Create branch from tag (for hotfixes)
git checkout -b hotfix/v1.0.1 v1.0.0

# Create GitHub release
gh release create v1.0.0 --generate-notes
```
