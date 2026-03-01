---
name: executing-plans
description: "Batch execution of written implementation plans with review checkpoints and progress tracking. Triggers when the user says 'execute the plan', 'run the plan', 'start implementing', or when there is an existing plan file or TodoWrite list to work through."
version: "1.0"
---

# Executing Plans Skill

You are executing a pre-written implementation plan. Follow it step by step. Do NOT improvise, skip steps, or reorder unless a blocking issue forces adaptation.

## When to Use

- After the **planning** skill has produced a plan
- When the user says "execute", "run the plan", "start implementing"
- When there's a TodoWrite list with pending steps
- When resuming work on a partially-completed plan

## Execution Protocol

### Phase 1: Load and Verify the Plan

1. Read the plan file or TodoWrite list
2. Count total steps and identify checkpoints
3. Check which steps are already completed (if resuming)
4. Verify prerequisites are met (dependencies installed, files exist, etc.)
5. Report to user: "Plan has N steps, M checkpoints. Steps 1-K already completed. Starting from step K+1."

### Phase 2: Execute in Batches

Execute steps in batches of 3-5, following this cycle:

```
For each step in the batch:
  1. Announce: "Executing Step N: [title]"
  2. Read the target file (if modifying existing)
  3. Make the change using the RARV loop:
     - Reason: What am I doing and why?
     - Act: Make the edit/create the file
     - Reflect: Does this look right? Any side effects?
     - Verify: Run the acceptance check for this step
  4. Mark step as completed in TodoWrite
```

After each batch:
  - Run the test suite for affected code
  - Report: "Batch complete. Steps N-M done. X tests passing. Proceeding to next batch."

### Phase 3: Checkpoint Review

At each checkpoint step in the plan:

1. **Stop execution**
2. Run the checkpoint verification command
3. Report results to the user
4. **Wait for user confirmation** before continuing

Format:
```
CHECKPOINT: [checkpoint description]
- Tests: X passing, Y failing
- Lint: clean / N issues
- Changes: [list files modified since last checkpoint]

Ready to continue? (Or should I address the failing tests first?)
```

### Phase 4: Completion

After all steps:

1. Run the full test suite
2. Run the linter
3. Report final status:
```
PLAN COMPLETE: [plan title]
- Steps executed: N/N
- Tests: X passing, Y failing
- Lint: clean / N issues
- Files created: [list]
- Files modified: [list]
```

## Handling Failures

### Test Failure During Execution

1. Stop the current batch
2. Read the test output carefully
3. Determine if the failure is:
   - **From the current step** -> Fix it before continuing
   - **Pre-existing** -> Note it and continue (do not fix unrelated failures)
   - **From a dependency** -> Go back and fix the dependency step first
4. Never mark a step as completed if its acceptance check fails

### Step Cannot Be Executed

If a step's prerequisites aren't met or the instructions are ambiguous:

1. Stop and report: "Step N cannot be executed: [reason]"
2. Suggest a fix or ask the user for clarification
3. Do NOT skip the step and continue — the plan is sequential for a reason

### Plan Needs Modification

If you discover the plan is wrong (missing steps, wrong file paths, etc.):

1. Stop execution
2. Report what's wrong
3. Propose the correction
4. Wait for user approval before modifying the plan
5. Resume execution

## Progress Tracking

Update TodoWrite after EVERY step:

```
TodoWrite([
  { id: "step-1", content: "...", status: "completed" },
  { id: "step-2", content: "...", status: "completed" },
  { id: "step-3", content: "...", status: "in_progress" },  // current
  { id: "step-4", content: "...", status: "pending" },
  ...
])
```

## Rules

- **Never skip a step** — even if it seems trivial or redundant
- **Never reorder steps** — the plan author sequenced them for a reason
- **Always run tests** at batch boundaries and checkpoints
- **Always announce** what you're doing before doing it
- **Stop at checkpoints** — they exist because the plan author wanted a review point
- **Mark progress** — if the session ends mid-plan, the next session must know where to resume
