---
name: blind-review
description: Perform a blind code review where the reviewer has zero knowledge of the implementation intent, plan, or conversation history. Reads ONLY the changed files and judges the code purely on its own merits -- removing anchoring bias from knowing what the developer was trying to achieve. Assesses code quality across readability, correctness, error handling, naming, test coverage, and security. Rates overall quality 0-100 and flags specific issues with line references. Use after any implementation to get an unbiased assessment of code quality. The reviewer should NOT know what the developer was trying to build.
allowed-tools: Read, Grep, Glob, Bash
---

# Blind Code Review

You are performing a BLIND code review. You have zero knowledge of the implementation plan, the conversation that led to this code, or what the developer intended. You judge the code purely on its own merits.

## What to Review
$ARGUMENTS
(If no specific files given, find recently modified files via `git diff --name-only HEAD~1` or `git status`)

## Rules of Blind Review

1. **Do NOT read** any plan, spec, design doc, conversation history, or task description
2. **Do NOT ask** what the code is supposed to do -- infer it from the code itself
3. **Read ONLY** the source files and their tests
4. If you cannot understand what the code does from reading it, that is a finding (poor readability)

## Review Process

### Step 1: Identify Changed Files

```bash
git diff --name-only HEAD~1
# or
git diff --staged --name-only
```

Read each changed file in full.

### Step 2: Assess Code Quality (6 dimensions)

For each file, evaluate:

**Readability (0-20)**
- Can you understand the purpose without external context?
- Are function/variable names self-documenting?
- Is the code organized logically?
- Are comments useful (explain WHY, not WHAT)?
- Is complexity appropriate for the task?

**Correctness (0-20)**
- Are there obvious logic errors?
- Are edge cases handled (empty input, null, zero, max values)?
- Are types used correctly?
- Do loops terminate correctly?
- Are return values handled?

**Error Handling (0-20)**
- Are exceptions caught at appropriate levels?
- Are errors logged with useful context?
- Is there silent error swallowing?
- Do async operations have proper error boundaries?
- Are error messages helpful for debugging?

**Naming & Structure (0-15)**
- Do names convey intent?
- Is there unnecessary abbreviation?
- Are modules/classes at the right level of abstraction?
- Is the file doing too many things (SRP violation)?

**Test Coverage (0-15)**
- Do tests exist for the changed code?
- Do tests cover the happy path?
- Do tests cover edge cases?
- Are tests testing behavior (not implementation)?
- Would the tests catch a regression?

**Security (0-10)**
- User input validation
- SQL injection potential
- Secrets in source
- Access control checks
- Data exposure in logs/errors

### Step 3: Rate and Report

Output format:

```
## Blind Review Report

### Files Reviewed
- path/to/file1.py
- path/to/file2.py

### Overall Score: XX/100

### Dimension Scores
| Dimension | Score | Notes |
|-----------|-------|-------|
| Readability | X/20 | ... |
| Correctness | X/20 | ... |
| Error Handling | X/20 | ... |
| Naming & Structure | X/15 | ... |
| Test Coverage | X/15 | ... |
| Security | X/10 | ... |

### Issues Found
[SEVERITY] file:line -- description

### What This Code Appears To Do
(Your inference from reading only the code)

### Verdict
SHIP / REVISE / BLOCK
```

**Verdicts:**
- **SHIP** (80+): Code is clean, well-tested, ready for production
- **REVISE** (50-79): Has issues that should be fixed before merging
- **BLOCK** (<50): Significant problems that need rework
