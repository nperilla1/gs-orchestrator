---
name: gs:start
description: "Begin autonomous task execution. Reads a task, brainstorms approaches, creates a plan, and executes it end-to-end using the full skill pipeline."
arguments:
  - name: task
    description: "Description of the task to execute (optional -- will prompt if not provided)"
    required: false
---

# /gs:start -- Autonomous Task Execution

You are launching the full autonomous pipeline. This command chains brainstorming, planning, and execution into a single flow. The user provides a task description, and you drive it to completion.

## Pipeline

```
[Task Description]
      |
      v
  BRAINSTORMING (explore approaches, evaluate tradeoffs)
      |
      v
  PLANNING (create concrete, step-by-step implementation plan)
      |
      v
  EXECUTION (execute plan with checkpoints, tests, and progress tracking)
      |
      v
  [Completion Report]
```

## Step 1: Capture the Task

If the user provided a task description with the command, use it. Otherwise, ask:

> What would you like me to build, fix, or implement? Be as specific as possible -- include file names, expected behavior, and any constraints.

Confirm understanding by restating the task in one sentence.

## Step 2: Preflight Check

Before brainstorming, verify the environment:

1. Check SSH connectivity (non-blocking, 3s timeout)
2. Check DB tunnel is active on port 5434
3. Identify the current project (from cwd or state.json)
4. Check git status (clean working tree? which branch?)

Report any issues but do not block unless critical infrastructure is down.

## Step 3: Brainstorm

Invoke the **brainstorming** skill. Follow its full 5-step protocol:

1. Clarify the goal -- define concrete acceptance criteria
2. Explore at least 3 approaches
3. Evaluate tradeoffs with a comparison table
4. Run the 12-category completeness audit
5. Present recommended approach

Do NOT ask for user confirmation here -- in autonomous mode, select the best approach and proceed. If two approaches are very close, briefly note why you chose one over the other.

## Step 4: Plan

Invoke the **planning** skill. Create a full implementation plan with:

- Numbered steps with file paths and exact changes
- Acceptance criteria for each step
- Checkpoints every 3-5 steps
- Dependency annotations

Register all steps with TodoWrite for tracking.

## Step 5: Execute

Invoke the **executing-plans** skill. Follow its full protocol:

1. Load and verify the plan
2. Execute in batches of 3-5 steps
3. Run tests at batch boundaries
4. Stop at checkpoints for verification (but in autonomous mode, only stop if tests fail)
5. Handle failures by fixing and retrying

## Step 6: Completion Report

After all steps are executed, produce a final report:

```
TASK COMPLETE: [task title]
============================

Approach: [which approach was selected and why]

Steps Executed: N/N
Files Created: [list with paths]
Files Modified: [list with paths]

Test Results:
  - Total: X tests
  - Passing: Y
  - Failing: Z (with details if any)

Lint: clean / N issues
Type Check: clean / N issues

Key Decisions Made:
  1. [decision and rationale]
  2. [decision and rationale]

Open Questions:
  - [anything that needs user review]

Next Steps:
  - [suggested follow-up work]
```

## Autonomous Mode Rules

- In autonomous mode, do not ask for confirmation between phases -- flow from brainstorming to planning to execution seamlessly
- DO stop if tests fail and you cannot fix them after 2 attempts
- DO stop if a step requires information only the user can provide (e.g., API keys, business decisions)
- DO stop at the completion report to let the user review
- If the task is too large (plan exceeds 20 steps), split into sub-tasks and execute the first one, then report what remains

## Guardrails

- Never modify test files (the protect-files hook will block this anyway)
- Never commit or push without explicit user permission
- Never modify production data via SSH
- If the task involves security-sensitive changes (auth, credentials, permissions), stop and ask for review before executing
