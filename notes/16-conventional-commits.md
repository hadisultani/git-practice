# 16 — Conventional Commits

## What it is

Conventional Commits is a lightweight convention for writing commit messages.
It gives commit messages a consistent, machine-readable structure — which makes
history easier to read, changelogs easier to generate, and CI pipelines
easier to build rules around.

Used throughout this book's own commit history and all the examples in earlier chapters.

---

## 1. The format

```
type(scope): description

[optional body]

[optional footer]
```

### Examples

```
feat: add user authentication
fix: handle empty email on login form
docs: update README with setup steps
chore: upgrade dependencies
refactor: extract payment logic into service
test: add unit tests for auth module
ci: add GitHub Actions workflow
feat(auth): add OAuth2 login
fix(payments)!: change invoice ID format
```

---

## 2. Types

| Type | When to use |
|---|---|
| `feat` | A new feature visible to users |
| `fix` | A bug fix |
| `docs` | Documentation only — no code changes |
| `refactor` | Code restructured with no behaviour change |
| `test` | Adding or updating tests |
| `chore` | Maintenance — dependency updates, build scripts, tooling |
| `style` | Formatting, whitespace — no logic change |
| `perf` | Performance improvement |
| `ci` | Changes to CI/CD configuration |
| `build` | Changes to the build system |
| `revert` | Reverts a previous commit |

### The two that matter most

`feat` and `fix` are the only two that directly communicate product value.
When in doubt, decide between these two first, then use the others for
everything else.

---

## 3. Scope (optional)

Scope narrows the type to a specific area of the codebase.
Put it in parentheses after the type.

```
feat(auth): add OAuth2 login
fix(payments): handle null invoice ID
docs(api): add endpoint reference
chore(deps): upgrade React to 18.3
```

Scope is optional. Use it when the repo has clear subsystems and it helps
readers understand where the change is without reading the code.

---

## 4. Breaking changes

Append `!` to signal a breaking change:

```
feat(api)!: change authentication endpoint from /auth to /v2/auth
fix!: remove deprecated getUserById method
```

Or use a footer:

```
feat: change payment provider

BREAKING CHANGE: the PaymentResult shape has changed.
Fields `amount` and `currency` are now nested under `charge`.
```

Breaking changes map to a **major version bump** in semantic versioning.

---

## 5. Body and footer

The body gives context — why the change was made, not just what.
Use it for anything that won't fit in 72 characters.

```
fix(auth): handle session expiry on slow networks

On high-latency connections the token refresh was racing with the
session check, causing users to be logged out mid-session. Fixed by
adding a 5-second grace period before treating an expiry as final.

Closes #142
Reviewed-by: Alice Smith
```

Common footer tokens:

```
Closes #42          ← closes a GitHub issue when merged
Fixes #99           ← same
Refs #11            ← references without closing
BREAKING CHANGE:    ← describes what breaks and how to migrate
Co-authored-by:     ← credits contributors
Reviewed-by:        ← credits reviewer
```

---

## 6. The description rules

```
feat: add login form       ← good — lowercase, imperative, no period
feat: Added login form     ← bad — past tense
feat: add login form.      ← bad — trailing period
feat: Add Login Form       ← bad — title case
Feat: add login form       ← bad — type must be lowercase
```

- Lowercase
- Imperative mood ("add", "fix", "update" — not "added", "fixed")
- No trailing period
- 72 characters max for the description line

---

## 7. Why it matters

### Readable history

```bash
git log --oneline

# Without convention:
abc1234  stuff
def5678  fix things
ghi9012  updated

# With conventional commits:
abc1234  feat(auth): add OAuth2 login
def5678  fix(payments): handle null invoice ID
ghi9012  docs: update API reference
```

### Automated changelogs

Tools like `conventional-changelog` and `release-please` parse your commit
history and generate a `CHANGELOG.md` automatically:

```markdown
## [1.2.0] - 2024-06-01

### Features
- auth: add OAuth2 login (abc1234)

### Bug Fixes
- payments: handle null invoice ID (def5678)
```

### Semantic version automation

| Commit type | Version bump |
|---|---|
| `fix` | PATCH (1.0.0 → 1.0.1) |
| `feat` | MINOR (1.0.0 → 1.1.0) |
| `feat!` or `BREAKING CHANGE` | MAJOR (1.0.0 → 2.0.0) |

### CI filtering

GitHub Actions can trigger different pipelines based on commit type:

```yaml
# Only run deploy on feat/fix commits, not docs or chore
if: startsWith(github.event.head_commit.message, 'feat') || startsWith(github.event.head_commit.message, 'fix')
```

---

## 8. Enforcement tools

```bash
# commitlint — validates commit messages against the convention
npm install --save-dev @commitlint/cli @commitlint/config-conventional

# commitizen — interactive CLI prompt for writing conforming messages
npm install --save-dev commitizen
git cz   # instead of git commit

# Add as a git hook so every commit is validated automatically
npm install --save-dev husky
npx husky add .husky/commit-msg 'npx commitlint --edit $1'
```

---

## Quick reference

```
feat: add user authentication
fix: handle empty email on login
docs: update setup guide
chore: upgrade dependencies
refactor: extract auth logic
test: add login form tests
ci: add CI workflow

feat(scope): description
fix!: breaking change description

BREAKING CHANGE: description of what breaks and migration path

Closes #42
```
