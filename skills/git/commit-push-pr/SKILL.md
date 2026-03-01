---
name: commit-push-pr
description: "Full commit, push, and pull request workflow. Commits changes, pushes the branch, and creates a PR with a summary and test plan via gh CLI."
allowed-tools: Bash, Read, Grep, Glob
---

# Commit, Push, and PR Skill

You are executing the full cycle: commit changes, push the branch to remote, and create a pull request. This builds on the commit skill and adds push + PR creation.

## When to Use

- When the user says "ship it", "create a PR", "push and make a PR"
- After a feature branch is complete and ready for review
- When the user explicitly asks to push changes

## Protocol

### Step 1: Commit (if needed)

Check if there are uncommitted changes:

```bash
git status --porcelain
```

If there are changes, follow the commit skill protocol (stage, message, commit). If the working tree is clean, skip to step 2.

### Step 2: Determine Branch State

```bash
git branch --show-current
git log --oneline origin/main..HEAD 2>/dev/null || git log --oneline origin/master..HEAD 2>/dev/null
```

Determine:
- Current branch name
- How many commits ahead of main/master
- Whether the branch has a remote tracking branch

### Step 3: Push

```bash
# If no upstream tracking branch exists
git push -u origin $(git branch --show-current)

# If tracking branch exists
git push
```

Verify the push succeeded:
```bash
git log --oneline origin/$(git branch --show-current) -1
```

### Step 4: Analyze Changes for PR

Review ALL commits that will be in the PR (not just the latest):

```bash
git log --oneline main..HEAD
git diff main...HEAD --stat
git diff main...HEAD
```

Understand the full scope of changes across all commits.

### Step 5: Create Pull Request

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
- <bullet point 1: what changed>
- <bullet point 2: what changed>
- <bullet point 3: why it changed>

## Test plan
- [ ] Unit tests pass (`pytest tests/ -v`)
- [ ] Lint clean (`ruff check src/`)
- [ ] Type check clean (`mypy src/ --strict`)
- [ ] <specific manual verification steps>

## Related
- Closes #<issue> (if applicable)
- Related to #<issue> (if applicable)

---
Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

**PR Title Rules:**
- Under 70 chars
- Imperative mood
- No period at the end
- Include the type prefix if the repo uses conventional commits

**PR Body Rules:**
- Summary: 1-3 bullet points covering WHAT and WHY
- Test plan: Specific, checkable items
- Related issues: Link with `Closes #N` or `Related to #N`

### Step 6: Report

```
PR Created
==========
URL:    <pr-url>
Title:  <title>
Branch: <branch> -> main
Commits: N
Files:   M changed

Next steps:
  - Request review from [suggested reviewers]
  - Monitor CI checks
```

## Rules

- NEVER push to main/master directly
- NEVER force push unless explicitly asked (and warn before doing so)
- Always use `-u` flag on first push to set upstream tracking
- PR title should be under 70 chars
- PR body must include both a summary and test plan
- If there are no commits to push (branch is up to date), report that and skip
- If `gh` CLI is not installed, report the error and suggest installing it
- Return the PR URL at the end so the user can click through
