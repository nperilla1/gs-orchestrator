---
name: planning
description: "Write bite-sized, executable implementation plans with file paths, exact changes, and acceptance criteria. Triggers when the user wants to plan work, break down a task, create a roadmap, organize implementation steps, or prepare before coding."
version: "1.0"
---

# Planning Skill

You are creating an implementation plan. Every step must be concrete enough that a developer (or agent) can execute it without asking clarifying questions.

## When to Use

- After brainstorming, to turn a chosen approach into actionable steps
- When a task is too large to execute in one shot
- When the user says "plan this", "break this down", "what are the steps"
- Before any multi-file change that touches more than 3 files

## Plan Structure

### Header

```
# Plan: [Short Title]
## Goal: [One sentence]
## Scope: [What's in / what's out]
## Estimated Steps: [N]
## Dependencies: [Other plans, external services, data]
```

### Steps

Each step MUST include ALL of these fields:

```
### Step N: [Action Verb] [Object]
- **File**: `path/to/file.py` (or "NEW: path/to/new_file.py")
- **Change**: [Exact description of what to add/modify/remove]
- **Why**: [One sentence — why this step exists]
- **Acceptance**: [How to verify this step is done correctly]
- **Checkpoint**: [yes/no — should we pause for review after this step?]
```

### Rules for Good Steps

1. **One file per step** — if a change touches multiple files, split into multiple steps
2. **Name the file** — absolute path. If the file doesn't exist yet, prefix with "NEW:"
3. **State line numbers** when modifying existing code — "Add after line 45" or "Replace lines 12-18"
4. **Small steps** — each step should be completable in under 5 minutes
5. **Testable steps** — every 3-5 steps should have a verification point (run tests, check output)
6. **Order matters** — steps must be sequenced so each builds on the previous
7. **No hand-waving** — "refactor the module" is not a step. "Extract function X from file Y into file Z" is.

### Checkpoints

Insert a checkpoint step every 3-5 implementation steps:

```
### Checkpoint: Verify [what]
- **Run**: `pytest tests/test_feature.py -v`
- **Expect**: All tests pass, no new warnings
- **If failing**: Stop and debug before continuing
```

### Dependencies Between Steps

If steps can run in parallel, note it:

```
### Steps 4-6 (PARALLEL — no dependencies between them)
```

If a step depends on another:

```
### Step 7: [Action]
- **Depends on**: Step 3 (needs the schema from that step)
```

## Using TodoWrite for Tracking

After creating the plan, register all steps with TodoWrite:

```
TodoWrite([
  { id: "step-1", content: "Step 1: Create models.py with Organization schema", status: "pending" },
  { id: "step-2", content: "Step 2: Add repository layer", status: "pending" },
  ...
])
```

Update status as steps complete: `pending` -> `in_progress` -> `completed`.

## Plan Size Guidelines

- **Small plan** (1 session): 5-10 steps, 1-3 files, no architecture changes
- **Medium plan** (2-3 sessions): 10-20 steps, 3-8 files, may include new modules
- **Large plan** (multi-session): 20+ steps — MUST be split into sub-plans with clear interfaces

If a plan exceeds 20 steps, split it. Each sub-plan should produce a working, testable increment.

## Example Step

```
### Step 3: Add validation to OrganizationCreate schema
- **File**: `src/writer/schemas/organization.py`
- **Change**: Add field validators for `ein` (format: XX-XXXXXXX), `name` (min 2 chars, max 200), and `state` (must be valid US state code). Import `field_validator` from pydantic.
- **Why**: User-submitted org data needs validation before hitting the DB
- **Acceptance**: `pytest tests/test_schemas.py::test_organization_validation -v` passes with tests for valid input, invalid EIN, empty name, and bad state code
- **Checkpoint**: no
```

## Anti-Patterns

- Do NOT write plans with vague steps like "implement the feature" or "add tests"
- Do NOT create plans longer than 20 steps — split them
- Do NOT skip the acceptance criteria — every step needs a way to verify it worked
- Do NOT forget to sequence steps — a plan that can't be executed top-to-bottom is useless
- Do NOT plan work you don't understand — invoke the **brainstorming** skill first if the approach is unclear
