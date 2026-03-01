---
name: worktrees
description: "Git worktree isolation for parallel work. Creates a worktree with a new branch from HEAD, allowing independent work without disturbing the main working tree."
allowed-tools: Bash, Read
---

# Git Worktree Skill

You are setting up an isolated git worktree for parallel work. Worktrees allow multiple branches to be checked out simultaneously in different directories.

## When to Use

- When the user needs to work on something without disturbing current changes
- When exploring a risky approach that might need to be abandoned
- When running parallel tasks that touch the same files
- When the user says "worktree", "isolate this work", "parallel branch"

## Protocol

### Step 1: Check Prerequisites

```bash
# Must be in a git repo
git rev-parse --is-inside-work-tree

# Must not already be in a worktree (worktrees can't nest)
git rev-parse --show-toplevel
git worktree list
```

If already in a worktree, report that and suggest switching back to the main tree first.

### Step 2: Create the Worktree

```bash
# Generate a name if not provided
WORKTREE_NAME="${1:-$(date +%Y%m%d-%H%M%S)-$(openssl rand -hex 3)}"
BRANCH_NAME="worktree/$WORKTREE_NAME"
WORKTREE_DIR=".claude/worktrees/$WORKTREE_NAME"

# Create worktree with new branch from HEAD
git worktree add "$WORKTREE_DIR" -b "$BRANCH_NAME" HEAD
```

### Step 3: Report

```
Worktree Created
================
Directory: <absolute path to worktree>
Branch:    worktree/<name>
Based on:  <current HEAD commit hash and message>

To work in this worktree:
  cd <worktree-path>

To return to main tree:
  cd <main-tree-path>

To remove when done:
  git worktree remove <worktree-path>
  git branch -d worktree/<name>
```

## Managing Worktrees

### List Worktrees
```bash
git worktree list
```

### Remove a Worktree
```bash
git worktree remove .claude/worktrees/<name>
git branch -d worktree/<name>
```

### Merge Work Back
```bash
# From the main tree
git merge worktree/<name>
# Then clean up
git worktree remove .claude/worktrees/<name>
git branch -d worktree/<name>
```

## Rules

- Worktrees always go in `.claude/worktrees/` to keep them organized
- Branch names always start with `worktree/` prefix for easy identification
- Always create from HEAD (current commit) unless the user specifies a different base
- Never create a worktree if there are uncommitted changes in the main tree -- warn the user first
- When cleaning up, remove the worktree directory THEN delete the branch
- Maximum 5 active worktrees (list and warn if approaching the limit)
