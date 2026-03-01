---
name: feature-dev
description: "End-to-end guided feature development workflow that chains brainstorming, planning, TDD, and review skills together. Triggers when the user asks to build a feature, add functionality, implement a requirement, or says 'build this', 'add this feature', 'implement X'."
version: "1.0"
---

# Feature Development Skill

You are guiding a feature from request to completion. This skill chains together other orchestration skills in the correct order. Do NOT skip steps. Each step produces outputs the next step needs.

## When to Use

- User asks to "build", "add", "implement", or "create" a feature
- A feature request or requirement needs to be turned into working code
- Any work that involves multiple files, new endpoints, or new business logic

## The 7 Steps

### Step 1: Understand the Feature Request

Before anything else, make sure you understand what's being asked.

1. Restate the feature in your own words
2. Ask clarifying questions if ANYTHING is ambiguous:
   - What's the input? What's the output?
   - Who uses this? (API consumer, end user, another service)
   - What are the edge cases the user cares about?
   - Are there existing patterns in the codebase to follow?
3. Define "done" — 3-5 concrete acceptance criteria

Do NOT proceed until the feature request is unambiguous. It is better to ask one round of questions now than to build the wrong thing.

### Step 2: Explore Existing Codebase

Search for related code before designing anything new.

1. Find similar features already implemented:
   - Use Grep to search for related function names, table names, route paths
   - Use Glob to find files with related names
   - Read existing implementations to understand patterns
2. Identify reusable components:
   - Existing models that can be extended
   - Existing repositories with patterns to follow
   - Existing services with similar logic
   - Existing tests that show testing patterns
3. Note any constraints:
   - Database schema conventions (naming, types, FKs)
   - API conventions (route structure, response format, auth)
   - Code organization conventions (where things go)

Report: "Found these related patterns: [list]. Will follow the same conventions."

### Step 3: Design the Approach

Invoke the **brainstorming** skill.

- Run the full brainstorming process (approaches, tradeoffs, 12-category audit)
- Focus on how the feature fits into the EXISTING architecture
- Recommend an approach
- Get user confirmation

### Step 4: Plan the Implementation

Invoke the **planning** skill.

- Break the chosen approach into concrete steps
- Each step names the file, the change, and the acceptance criteria
- Include checkpoint steps for test verification
- Define **task-contracts** for any steps that could run in parallel
- Register steps in TodoWrite

### Step 5: Implement with TDD

Invoke the **tdd** skill for each implementation step.

For each step in the plan:
1. RED: Write a test for the behavior this step adds
2. GREEN: Write the minimum code to pass
3. REFACTOR: Clean up
4. Use the **rarv-loop** skill as the inner loop for each change

Batch execution following the **executing-plans** skill:
- Execute 3-5 steps per batch
- Run full test suite after each batch
- Pause at checkpoints for review

### Step 6: Review

Invoke the **code-review** skill.

- Run all 5 review passes on the new code
- Fix any issues found (using RARV loop for each fix)
- Re-run tests after fixes

### Step 7: Verify and Complete

Final verification:

1. Run the full test suite: `pytest --tb=short -q`
2. Run the linter: `ruff check src/ tests/`
3. Fix any issues
4. Summarize what was built:
   ```
   FEATURE COMPLETE: [feature name]

   Files created:
   - path/to/new_file.py — [what it does]

   Files modified:
   - path/to/existing.py — [what changed]

   Tests:
   - N new tests, all passing
   - Full suite: X passing, 0 failing

   Acceptance criteria:
   - [x] Criterion 1
   - [x] Criterion 2
   - [x] Criterion 3
   ```

5. Suggest next action: invoke **finishing-branch** skill to commit/PR the work.

## Step Dependencies

```
Step 1 (Understand)
  └─> Step 2 (Explore)
       └─> Step 3 (Design) ← brainstorming skill
            └─> Step 4 (Plan) ← planning skill
                 └─> Step 5 (Implement) ← tdd + rarv-loop + executing-plans skills
                      └─> Step 6 (Review) ← code-review skill
                           └─> Step 7 (Verify) → finishing-branch skill
```

Each step's output feeds the next. Do not skip forward.

## Shortcuts for Small Features

If the feature is small (single file, <50 lines, single behavior):

1. Compress Steps 1-3 into a brief assessment (2-3 sentences)
2. Skip Step 4 (plan) — go straight to TDD
3. Compress Step 6 (review) into a quick self-review

State that you're using the abbreviated flow and why.

## Anti-Patterns

- **Jumping to code** — Skipping Steps 1-3 because "I already know what to build." You probably don't.
- **Ignoring existing patterns** — Building a new convention when the codebase already has one.
- **Skipping TDD** — "I'll add tests later" results in untested code or tests that test the implementation, not the behavior.
- **Skipping review** — Your own code has bugs. Review it systematically.
- **Incomplete verification** — "Tests pass" is not enough. Lint must be clean. Acceptance criteria must be met.
