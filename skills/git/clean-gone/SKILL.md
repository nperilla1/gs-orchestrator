---
name: clean-gone
description: "Clean up local branches that have been deleted on the remote (marked as [gone]). Also removes associated worktrees."
allowed-tools: Bash
---

# Clean Gone Branches Skill

You are cleaning up local branches whose remote tracking branches have been deleted. These branches show as `[gone]` after a `git fetch --prune`.

## When to Use

- After merging PRs on GitHub (the remote branch gets deleted)
- During periodic repo maintenance
- When `git branch -v` shows many stale branches
- When the user says "clean up branches", "remove merged branches"

## Protocol

### Step 1: Prune Remote Tracking References

```bash
git fetch --prune
```

This updates the remote tracking refs and marks deleted branches as `[gone]`.

### Step 2: Find Gone Branches

```bash
git branch -vv | grep ': gone]' | awk '{print $1}'
```

List all branches marked as `[gone]`.

### Step 3: Check for Associated Worktrees

```bash
git worktree list
```

For each gone branch, check if it has an active worktree. If so, the worktree must be removed first.

### Step 4: Preview Cleanup

Present the list to the user before deleting:

```
Branches to remove (remote deleted):
  - feature/old-feature (last commit: 3 days ago)
  - fix/resolved-bug (last commit: 1 week ago)
  - worktree/experiment-abc (has active worktree at .claude/worktrees/experiment-abc)

Branches to keep (no remote or still active):
  - main (current branch)
  - develop (remote exists)

Proceed with cleanup? (y/n)
```

### Step 5: Execute Cleanup

For each gone branch:

```bash
# If it has a worktree, remove that first
git worktree remove .claude/worktrees/<name> 2>/dev/null

# Delete the branch (use -d for safety, not -D)
git branch -d <branch-name>
```

If `-d` fails (branch not fully merged), report it and skip. Do NOT use `-D` unless the user explicitly confirms.

### Step 6: Report

```
Cleanup Complete
================
Removed: N branches
  - <branch-1>
  - <branch-2>

Skipped (not fully merged): M branches
  - <branch-3> (use -D to force delete)

Worktrees removed: K

Remaining branches:
  - main (current)
  - <other active branches>
```

## Rules

- NEVER delete the current branch
- NEVER delete main or master
- NEVER use `git branch -D` without explicit user confirmation per branch
- Always `git fetch --prune` first to get accurate status
- Always show the preview before deleting anything
- If a branch has unmerged commits, warn the user and skip it
- Remove associated worktrees before deleting branches
