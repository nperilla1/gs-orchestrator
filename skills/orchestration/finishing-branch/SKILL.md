---
name: finishing-branch
description: "Decision guide for completing development work — commit, PR, or cleanup. Triggers when work is done, the user says 'finish up', 'wrap this up', 'commit', 'create a PR', 'clean up', or when it's time to finalize a branch."
version: "1.0"
---

# Finishing Branch Skill

Development work is done. Now decide: commit, PR, or cleanup. Follow the pre-flight checklist, then take the right path.

## When to Use

- After completing a feature (Step 7 of **feature-dev** skill)
- When the user says "commit", "finish", "wrap up", "create a PR"
- When a branch has changes ready to be finalized
- When experimental work needs to be preserved or discarded

## Pre-Flight Checklist

Run these checks BEFORE deciding on a path. All must pass.

### 1. Tests

```bash
pytest --tb=short -q
```

- [ ] All tests pass
- [ ] No skipped tests that should be running
- [ ] No new warnings introduced

If tests fail: STOP. Use the **debugging** skill to fix them first.

### 2. Lint

```bash
ruff check src/ tests/
```

- [ ] No lint errors
- [ ] No formatting issues

If lint fails: Fix issues with `ruff check --fix src/ tests/` and `ruff format src/ tests/`.

### 3. Changes Are Complete

- [ ] All acceptance criteria met (from the plan or feature request)
- [ ] No TODO comments left in code (unless explicitly flagged to user)
- [ ] No debug print statements or temporary logging
- [ ] No commented-out code blocks

### 4. Changes Are Staged

```bash
git status
git diff
git diff --staged
```

- [ ] All intended changes are tracked (no untracked files that should be committed)
- [ ] No unintended changes (files you didn't mean to modify)
- [ ] No sensitive files (.env, credentials, API keys)

## Three Paths

### Path A: Direct Commit

**When**: Small, self-contained change. You're confident in the code. No team review needed.

Checklist:
- [ ] Pre-flight checks all pass
- [ ] Change is < 200 lines
- [ ] No architecture changes
- [ ] Existing tests cover the change
- [ ] You've run the **code-review** skill (or the change is trivial)

Steps:
1. Stage the files: `git add <specific files>` (prefer named files over `git add .`)
2. Write a commit message following repo conventions
3. Commit: `git commit -m "message"`
4. Verify: `git status` shows clean working tree

Commit message format:
```
<type>: <short description>

<body — what changed and why>

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`

### Path B: Create Pull Request

**When**: Change needs team review, touches shared code, or modifies architecture.

Checklist:
- [ ] Pre-flight checks all pass
- [ ] **Code-review** skill has been run
- [ ] All CRITICAL and HIGH issues from review are fixed
- [ ] Branch is up to date with base branch

Steps:
1. Commit all changes (Path A steps)
2. Push to remote: `git push -u origin <branch-name>`
3. Create PR with `gh pr create`:
   - Title: short, descriptive (<70 chars)
   - Body: summary bullets, test plan, and any notes for reviewers
4. Return the PR URL to the user

PR body template:
```
## Summary
- [what changed]
- [why it changed]

## Test plan
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual verification of [specific scenario]

Generated with [Claude Code](https://claude.com/claude-code)
```

### Path C: Cleanup (Experimental Branch)

**When**: The branch was experimental. Some work is worth keeping, some isn't.

Steps:
1. Identify what to keep vs. discard
2. If keeping some changes:
   - Cherry-pick valuable commits to a clean branch
   - Or manually copy specific files/functions
3. If discarding everything:
   - Confirm with user: "This will discard all changes on this branch. Confirm?"
   - Only proceed with explicit confirmation
4. Document what was learned (even from failed experiments)

## Post-Completion

After finishing any path:

1. Report what was done:
   ```
   BRANCH FINALIZED

   Path: [A/B/C]
   Commit(s): [hash(es)]
   PR: [URL if created]
   Files: [N files changed, N insertions, N deletions]
   Tests: [N passing]

   Next steps: [any follow-up work identified]
   ```

2. If there are follow-up tasks (identified during review, deferred improvements):
   - List them clearly
   - Suggest creating issues or adding to backlog

## Anti-Patterns

- **Committing failing tests** — never. Fix them first.
- **Committing lint errors** — never. Clean them first.
- **Giant commits** — if a commit touches 20+ files, it probably should have been multiple commits
- **Vague commit messages** — "fix stuff" or "updates" tells no one anything
- **Committing .env or secrets** — check `git diff --staged` before every commit
- **Skipping the PR for big changes** — if it touches architecture or shared code, get review
