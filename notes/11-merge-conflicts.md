# 11 — Merge Conflicts

## What a merge conflict is

A merge conflict happens when git tries to combine two branches and finds that
both branches have changed the same lines in the same file. Git cannot decide
which version is correct, so it stops and asks you to resolve it manually.

```
main:    line 5 says: "Welcome to the app"
feature: line 5 says: "Hello, welcome!"

git merge feature
# CONFLICT — git doesn't know which line you want. You decide.
```

Conflicts are normal. They are not errors. They just mean two pieces of work
overlapped and a human needs to make a judgment call.

---

## 1. When conflicts happen

```bash
git merge feature/my-branch       # merge can conflict
git rebase origin/main            # rebase can conflict (one commit at a time)
git pull                          # pull = fetch + merge/rebase, can conflict
git cherry-pick abc1234           # cherry-pick can conflict
```

---

## 2. The conflict markers

When git finds a conflict, it edits the file and inserts markers:

```
<<<<<<< HEAD
Welcome to the app
=======
Hello, welcome!
>>>>>>> feature/my-branch
```

Reading the markers:

```
<<<<<<< HEAD                ← start of YOUR version (the branch you're on)
Welcome to the app          ← your content
=======                     ← divider
Hello, welcome!             ← incoming content
>>>>>>> feature/my-branch   ← end of INCOMING version (the branch being merged)
```

The file may have multiple conflict blocks if several sections clashed.

---

## 3. Resolving a conflict

You have three choices for each conflict block:

1. Keep your version (remove the incoming content + all markers)
2. Keep the incoming version (remove your content + all markers)
3. Write something new that combines or replaces both

**You must remove all three marker lines** (`<<<<<<<`, `=======`, `>>>>>>>`).
Git won't accept a commit while markers remain in any file.

### Resolve manually in any editor

```
Before (conflicted):                After (resolved):

<<<<<<< HEAD                        Hello, welcome to the app!
Welcome to the app
=======
Hello, welcome!
>>>>>>> feature/my-branch
```

### Resolve in VS Code

VS Code detects conflict markers and shows action links above each block:

```
Accept Current Change | Accept Incoming Change | Accept Both Changes | Compare Changes
```

Click the option that's right for each block. The markers disappear automatically.

VS Code also has a **3-way merge editor** (more visual):
- Open the conflicted file
- Click "Resolve in Merge Editor" in the top right

---

## 4. After resolving — completing the merge

```bash
# 1. Check status — see which files still have conflicts
git status
# both modified: notes/README.md

# 2. Open each conflicted file and resolve all markers

# 3. Stage each resolved file
git add notes/README.md

# 4. Once all conflicts are staged, complete the merge
git commit
# Git pre-fills the commit message "Merge branch 'feature/x'"
# Save and close the editor to accept it
```

### All-in-one after resolving

```bash
git add .
git commit --no-edit    # accept the default merge commit message
```

---

## 5. Conflicts during rebase

Rebase replays your commits one at a time. If one conflicts, it pauses at that commit.

```bash
git rebase origin/main

# If a conflict occurs:
git status              # shows the conflicting files
# ... resolve the markers in each file ...
git add resolved-file.md
git rebase --continue   # apply the resolution and continue with next commit

# To skip the current commit entirely (use with caution)
git rebase --skip

# To give up and go back to before the rebase started
git rebase --abort
```

---

## 6. Aborting — undoing the merge entirely

If you get into a mess and want to start over:

```bash
# Abort a merge in progress
git merge --abort

# Abort a rebase in progress
git rebase --abort

# Abort a cherry-pick in progress
git cherry-pick --abort
```

This restores your branch to the state it was in before the operation started.

---

## 7. Preventing conflicts

Conflicts can't always be avoided, but frequency drops significantly with these habits:

```bash
# Keep your feature branch current with main
git fetch origin
git rebase origin/main        # do this daily on long-running branches

# Pull with rebase instead of merge
git pull --rebase             # or set globally: git config --global pull.rebase true

# Communicate — if you know a teammate is editing the same file, coordinate
```

Short-lived branches conflict less. The longer a branch lives and drifts from main,
the more likely it is to conflict on merge.

---

## 8. Useful tools for complex conflicts

```bash
# Launch a visual merge tool (configured in .gitconfig)
git mergetool

# Configure VS Code as your merge tool
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait $MERGED'

# Show the common ancestor version of a file (what it looked like before either branch changed it)
git show :1:filename.md     # common ancestor
git show :2:filename.md     # HEAD (your) version
git show :3:filename.md     # incoming version
```

---

## Quick reference

```bash
# See which files are conflicted
git status

# After resolving all markers in a file — mark it resolved
git add filename

# Complete the merge
git commit
git commit --no-edit        # accept auto-generated message

# Rebase conflict flow
git add resolved-file
git rebase --continue
git rebase --abort          # give up

# Abort everything and start over
git merge --abort
git rebase --abort
```
