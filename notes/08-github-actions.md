# 08 — GitHub Actions

## What GitHub Actions is

GitHub Actions is GitHub's built-in automation platform.
You describe automation in YAML files and GitHub runs them on its
own servers whenever a trigger event happens — a push, a PR, a schedule,
a release tag, or a manual button click.

The most common use is CI (continuous integration): every time someone
opens or updates a PR, Actions runs your test suite and reports pass/fail
directly on the PR. Branch protection rules can then block merging until
CI is green — making it impossible to ship broken code by accident.

```
Developer pushes to feature branch
        │
        ▼
GitHub Actions triggered
        │
        ├── Lint
        ├── Type check
        ├── Tests
        │
        ▼
    All pass? ──── ✅ ──► PR can be merged
                   ❌ ──► PR blocked, developer fixes and re-pushes
```

---

## 1. Core concepts

| Concept | What it is |
|---|---|
| **Workflow** | A YAML file in `.github/workflows/` — the top-level automation unit |
| **Trigger (on)** | The event that starts the workflow — push, pull_request, schedule, etc. |
| **Job** | A group of steps that run on one runner machine |
| **Step** | A single command or action within a job |
| **Action** | A reusable unit of work (e.g. `actions/checkout`, `actions/setup-node`) |
| **Runner** | The virtual machine GitHub provides to execute jobs |

### How they nest

```
Workflow (.github/workflows/ci.yml)
└── Job: build
    ├── Step: checkout code
    ├── Step: install dependencies
    └── Step: run tests
```

Multiple jobs in the same workflow run in parallel by default.
Use `needs:` to express dependencies between jobs.

---

## 2. Your first workflow — basic CI

Create the file `.github/workflows/ci.yml` in your repo.
GitHub picks it up automatically on the next push.

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test
```

What each part does:

```
name:        label shown in the GitHub UI
on:          triggers — runs on push to main AND on any PR targeting main
runs-on:     the OS image for the runner (ubuntu-latest is free and fast)
uses:        pulls in a community action from github.com/actions/...
run:         runs a shell command directly on the runner
```

---

## 3. Common triggers

```yaml
on:
  push:                        # any push to these branches
    branches: [main, develop]

  pull_request:                # PR opened, updated, or reopened
    branches: [main]

  schedule:                    # cron syntax — runs at set times
    - cron: '0 9 * * 1'        # every Monday at 9am UTC

  workflow_dispatch:           # adds a manual "Run workflow" button in GitHub UI
```

You can combine multiple triggers under the same `on:` key.

---

## 4. Environment variables and secrets

Never hardcode credentials in workflow files.
Store them as **encrypted secrets** in GitHub and read them as env vars.

### Adding a secret

**Repo → Settings → Secrets and variables → Actions → New repository secret**

```
Name:   NPM_TOKEN
Value:  npm_xxxxxxxxxxxx
```

### Using a secret in a workflow

```yaml
steps:
  - name: Publish to npm
    run: npm publish
    env:
      NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```

`${{ secrets.NAME }}` is the syntax to reference any secret.
The value is masked in logs — GitHub replaces it with `***`.

### Context variables

```yaml
steps:
  - name: Print context
    run: |
      echo "Branch: ${{ github.ref_name }}"
      echo "Commit: ${{ github.sha }}"
      echo "Actor:  ${{ github.actor }}"
      echo "Event:  ${{ github.event_name }}"
```

---

## 5. Caching dependencies

Without caching, every run re-downloads your packages from scratch.
With caching, the first run saves the cache and subsequent runs restore it —
dramatically faster.

```yaml
steps:
  - uses: actions/checkout@v4

  - uses: actions/setup-node@v4
    with:
      node-version: 20
      cache: npm          # built-in npm cache in setup-node

  - run: npm ci           # uses cache when available
  - run: npm test
```

For more control, use the `actions/cache` action directly:

```yaml
  - name: Cache node_modules
    uses: actions/cache@v4
    with:
      path: ~/.npm
      key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
      restore-keys: |
        ${{ runner.os }}-node-
```

The cache key changes whenever `package-lock.json` changes,
ensuring a fresh install when dependencies update.

---

## 6. Running multiple jobs

Jobs run in parallel unless you declare dependencies with `needs:`.

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm test

  deploy:
    runs-on: ubuntu-latest
    needs: [lint, test]        # only runs if both lint and test pass
    if: github.ref == 'refs/heads/main'   # only on main branch
    steps:
      - uses: actions/checkout@v4
      - run: npm run deploy
```

```
lint ──┐
       ├──► deploy (only if both pass, only on main)
test ──┘
```

---

## 7. Matrix builds — test across multiple versions

A matrix runs the same job with different variable combinations.

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18, 20, 22]

    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm ci
      - run: npm test
```

This creates three parallel jobs — one per Node.js version.
All three must pass for the matrix job to be considered passing.

---

## 8. Connecting Actions to branch protection

This is how CI becomes mandatory before merging.
After your workflow has run at least once, the check name appears in
GitHub's branch protection settings.

**Repo → Settings → Branches → edit main rule → Require status checks to pass**

```
Search for your check name:
  build          ← matches the job name from your workflow
  lint
  test

✅ Add each check you want to be required
✅ Require branches to be up to date before merging
```

Once added, the PR merge button stays blocked until all required
checks are green:

```
Pull Request #42
  ❌ build (CI) — failing     ← merge blocked
  ✅ lint (CI) — passed
```

---

## 9. Workflow file locations and naming

```
.github/
└── workflows/
    ├── ci.yml          ← runs on push/PR
    ├── release.yml     ← runs on version tags
    └── nightly.yml     ← runs on schedule
```

Rules:
- Must be in `.github/workflows/` at the root of your repo
- File extension must be `.yml` or `.yaml`
- The `name:` field sets the display name in the GitHub UI
- Job names become the check names in branch protection

---

## 10. Useful community actions

```yaml
# Checkout your repo
- uses: actions/checkout@v4

# Set up Node.js
- uses: actions/setup-node@v4
  with:
    node-version: 20

# Set up Python
- uses: actions/setup-python@v5
  with:
    python-version: '3.12'

# Upload a build artifact (makes it downloadable from the Actions UI)
- uses: actions/upload-artifact@v4
  with:
    name: build-output
    path: dist/

# Download a previously uploaded artifact
- uses: actions/download-artifact@v4
  with:
    name: build-output

# Comment on a PR from a workflow
- uses: actions/github-script@v7
  with:
    script: |
      github.rest.issues.createComment({
        issue_number: context.issue.number,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body: 'CI passed ✓'
      })
```

---

## Quick reference

```bash
# Workflow file goes here
mkdir -p .github/workflows
touch .github/workflows/ci.yml

# View workflow runs from the terminal
gh run list
gh run list --branch feature/my-branch

# Watch a run in real time
gh run watch

# View details of a specific run
gh run view 12345678

# View logs for a failed run
gh run view 12345678 --log-failed

# Re-run a failed workflow
gh run rerun 12345678

# Re-run only failed jobs
gh run rerun 12345678 --failed-only

# Trigger a workflow_dispatch workflow manually
gh workflow run ci.yml
gh workflow run ci.yml --ref feature/my-branch

# List all workflows
gh workflow list
```
