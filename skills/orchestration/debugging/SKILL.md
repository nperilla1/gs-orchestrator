---
name: debugging
description: "Systematic 4-phase root cause analysis for bugs, errors, test failures, and unexpected behavior. Triggers when something is broken, a test fails, an error occurs, the user reports a bug, or when behavior doesn't match expectations."
version: "1.0"
---

# Debugging Skill

You are in systematic debugging mode. Do NOT guess at fixes. Follow the four phases. The goal is to understand WHY something broke before changing ANY code.

## When to Use

- A test is failing
- An error or exception occurred
- Behavior doesn't match expectations
- The user says "it's broken", "this doesn't work", "there's a bug"
- After a deployment fails or a service is unhealthy

## The 4 Phases

### Phase 1: OBSERVE

Gather all available information BEFORE forming any hypothesis.

1. **Read the error message** — the full message, not just the summary. Read the ENTIRE stack trace.
2. **Identify the error type**:
   - Syntax error? (file + line number)
   - Runtime error? (what was the input?)
   - Logic error? (wrong output, not an exception)
   - Integration error? (works alone, fails when connected)
3. **Collect context**:
   - What changed recently? (check git diff, recent commits)
   - When did it start failing? (was it working before?)
   - Is it consistent or intermittent?
   - What are the inputs that trigger the failure?
4. **Reproduce the failure**:
   - Run the failing test in isolation: `pytest tests/file.py::test_name -v`
   - If no test exists, create a minimal reproduction
   - If intermittent, run 5-10 times to establish frequency

Format:
```
OBSERVE:
- Error: TypeError: 'NoneType' object is not subscriptable
- Location: src/writer/services/compiler.py, line 47, in compile_prompt()
- Stack trace shows: called from route handler -> service -> compiler
- Recent changes: Added cache layer in commit abc123
- Reproducible: Yes, always fails when section_id is None
```

Do NOT propose fixes during OBSERVE. Just collect facts.

### Phase 2: HYPOTHESIZE

Form 2-3 theories about the root cause. Rank by likelihood.

For each hypothesis:
1. **State the theory** — what do you think is wrong?
2. **What evidence supports it?** — from the OBSERVE phase
3. **What would confirm it?** — a specific check or experiment
4. **Likelihood** — High / Medium / Low

Format:
```
HYPOTHESIZE:

H1 (HIGH): section_id is None when called from the new cache path.
  Evidence: Error is NoneType subscript, cache key uses section_id.
  Confirm: Add logging to show section_id value at entry point.

H2 (MEDIUM): The cache is returning None instead of a cache miss.
  Evidence: Cache was recently added. Default return might be None.
  Confirm: Check cache.get() return value for missing keys.

H3 (LOW): Database returning NULL section_id for some records.
  Evidence: Would explain None, but worked before cache changes.
  Confirm: Query DB for records with NULL section_id.
```

Rules:
- Always generate at least 2 hypotheses — if you only have one, you're anchored
- The most obvious hypothesis is not always correct — consider alternatives
- Rank by likelihood but TEST the easiest-to-verify one first

### Phase 3: TEST

Validate each hypothesis with the minimum experiment needed. Do NOT fix the bug yet — just confirm the root cause.

For each hypothesis, in order of ease-of-verification:

1. **Design the experiment** — what's the simplest check?
2. **Run it** — add a print/log, query the DB, check the data
3. **Interpret the result** — does it confirm or reject the hypothesis?

Format:
```
TEST H1: Added `print(f"section_id={section_id}")` at line 40.
Result: section_id=None when called from /api/compile endpoint.
CONFIRMED: The route handler is not passing section_id from the request.

TEST H2: Not needed — H1 confirmed.
```

Rules:
- One experiment per hypothesis — do not change multiple things at once
- Use the LEAST invasive method: print statements > debugger > code changes
- Remove diagnostic code after testing (do not leave print statements)
- If all hypotheses are rejected, go back to OBSERVE and collect more data

### Phase 4: FIX

Now that you know the root cause, fix it properly.

1. **Identify the smallest fix** — change the minimum code to resolve the issue
2. **Apply the fix using the RARV loop**:
   - Reason: "Root cause is X, fixing by Y"
   - Act: Make the change
   - Reflect: Does this fix address the root cause, not just the symptom?
   - Verify: Run the failing test — it should now pass
3. **Check for regressions** — run the full test suite
4. **Check for siblings** — are there other places with the same bug pattern?

Format:
```
FIX:
- Root cause: Route handler extracts section_id from query params but
  the parameter is optional and defaults to None.
- Fix: Add required=True to the section_id parameter, or handle None
  gracefully in compile_prompt().
- Choice: Handle None gracefully — section_id is optional in other contexts.
- Change: Added `if section_id is None: return default_prompt()` guard in
  compile_prompt() at line 41.
- Verify: pytest tests/test_compiler.py -v → all pass including new test
  for None section_id.
- Siblings: Checked compile_strategy() and compile_review() — same pattern
  exists, adding guards there too.
```

## Common Debugging Patterns in GS Projects

### Database Issues
```bash
# Check if table exists
ssh gs-production-v2 "docker exec gs-backend psql -U n8n -d gs_unified -c '\dt writer.*'"

# Check column types
ssh gs-production-v2 "docker exec gs-backend psql -U n8n -d gs_unified -c '\d writer.project_sections'"

# Check for NULL values
ssh gs-production-v2 "docker exec gs-backend psql -U n8n -d gs_unified -c 'SELECT count(*) FROM writer.project_sections WHERE section_id IS NULL'"
```

### Import/Module Errors
- Check `__init__.py` exports
- Check `pyproject.toml` package configuration
- Verify virtual environment is activated
- Run `pip list | grep package-name`

### Async/Await Issues
- Missing `await` on async function call (returns coroutine object instead of result)
- Using sync DB operations inside async context
- Not closing sessions/connections properly

### Pydantic V2 Issues
- Silent field dropping (unknown fields ignored by default)
- `model_validate()` vs `model_construct()` (validation vs no validation)
- JSON serialization of UUIDs, datetimes, enums

## Anti-Patterns

- **Shotgun debugging**: Changing random things and hoping one works. Follow the phases.
- **Fixing symptoms**: The error is in file A but the bug is in file B. Fix the root cause.
- **Skipping OBSERVE**: "I know what's wrong" — you often don't. Collect evidence first.
- **Single hypothesis**: If you only have one theory, you're biased. Generate alternatives.
- **Fixing without verifying**: Make the change, run the test. Every time.
- **Leaving diagnostic code**: Remove all print statements and temporary logging after debugging.
