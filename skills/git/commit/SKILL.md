---
name: commit
description: "Smart git commit with auto-generated conventional commit message. Reads the diff, stages relevant files, and creates a commit following the repo's conventions."
allowed-tools: Bash, Read, Grep, Glob
---

# Smart Commit Skill

You are creating a well-crafted git commit. Read the diff, understand the changes, generate an appropriate commit message, and commit.

## When to Use

- After completing a feature, fix, or refactor
- When the user says "commit", "save my changes", "commit this"
- At the end of a planning/execution cycle

## Protocol

### Step 1: Assess Changes

```bash
git status
git diff --stat
git diff --cached --stat
git diff
```

Understand what changed, why, and how many files are involved.

### Step 2: Stage Files

Stage files selectively -- NEVER use `git add -A` or `git add .`:

```bash
git add src/specific/file.py src/other/file.py
```

Rules for staging:
- Stage only files related to the current logical change
- NEVER stage `.env`, credentials, secrets, `.key`, `.pem` files
- NEVER stage large binary files or build artifacts
- If there are unrelated changes, create separate commits for each logical unit

### Step 3: Generate Commit Message

Follow conventional commit format:

```
<type>(<scope>): <subject>

<body>

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
```

**Types:**
| Type | When |
|------|------|
| feat | New feature or capability |
| fix | Bug fix |
| refactor | Code restructuring without behavior change |
| test | Adding or updating tests |
| docs | Documentation changes |
| chore | Build, CI, dependency updates |
| perf | Performance improvement |
| style | Formatting, whitespace (no logic change) |

**Scope:** The module, component, or area affected (e.g., `writer`, `api`, `db`, `hooks`)

**Subject:** Imperative mood, lowercase, no period, under 50 chars

**Body:** Explain WHY the change was made, not WHAT changed (the diff shows what). Wrap at 72 chars.

### Step 4: Check Repo Conventions

```bash
git log --oneline -10
```

Match the existing commit style. If the repo uses different conventions (e.g., no type prefix, ticket numbers), adapt accordingly.

### Step 5: Commit

```bash
git commit -m "$(cat <<'EOF'
<type>(<scope>): <subject>

<body>

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

### Step 6: Verify

```bash
git log --oneline -1
git status
```

Confirm the commit was created and the working tree is in the expected state.

## Rules

- ONE logical change per commit (split if multiple unrelated changes exist)
- Never commit test files unless the change IS the tests
- Never commit secrets or credentials (the protect-files hook should catch this, but double-check)
- Always include the Co-Authored-By trailer
- If pre-commit hooks fail, fix the issue and create a NEW commit (do not amend)
- Verify git status after committing to confirm success
