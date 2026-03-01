---
name: rarv-loop
description: "Reason/Act/Reflect/Verify atomic work cycle that enforces thinking before acting on every code change. Triggers for any implementation work, code edits, bug fixes, refactoring, or when you need a disciplined inner loop to avoid careless mistakes."
version: "1.0"
---

# RARV Loop Skill

Every unit of work follows the same four-phase cycle: Reason, Act, Reflect, Verify. This is the inner loop for ALL implementation work. It prevents the most common failure mode: acting before thinking.

## When to Use

- During any code change (feature, fix, refactor)
- As the inner loop inside the **executing-plans** skill
- When you catch yourself about to make a change without explaining why
- When a previous change introduced a bug — slow down and use RARV

## The Cycle

### R — Reason (BEFORE touching any code)

Answer these questions out loud (in your response):

1. **What** am I about to change? (file, function, line range)
2. **Why** does this change need to happen? (requirement, bug, cleanup)
3. **What could go wrong?** (breaking imports, type mismatches, side effects)
4. **What's my rollback?** (can I undo this easily if it's wrong?)

Format:
```
REASON: Modifying `src/writer/services/compiler.py`, function `compile_prompt()`.
Adding a cache check before the expensive template rendering.
Risk: Cache key collisions if section_id is not unique across grants.
Rollback: Remove the cache check — the function works without it.
```

If you cannot articulate WHY, stop. Go back to the **brainstorming** skill.

### A — Act (Make the change)

- Make exactly ONE logical change
- Do not combine multiple unrelated changes in one Act phase
- Use the Edit tool for surgical modifications, Write tool only for new files
- Keep the change small — if it touches more than ~30 lines, consider splitting

What counts as one logical change:
- Add a function
- Modify a function's behavior
- Add/change an import
- Fix a single bug
- Add a test case

What does NOT count as one change:
- "Refactor the whole module" (split into individual function changes)
- "Add feature X" (split into model + service + route + tests)

### R — Reflect (AFTER the change, BEFORE testing)

Pause and review what you just did:

1. **Re-read the changed code** — does it look right?
2. **Check for obvious issues**:
   - Typos in variable/function names?
   - Missing imports?
   - Off-by-one errors?
   - Hardcoded values that should be configurable?
   - Type annotation mismatches?
3. **Consider side effects**:
   - Does this change break any callers of the modified function?
   - Does this change the function's contract (inputs/outputs)?
   - Are there other places that need the same change?

Format:
```
REFLECT: Added cache lookup in compile_prompt(). The cache key uses
f"{grant_id}:{section_id}" which is unique per project instance.
No callers are affected — the function signature is unchanged.
Spotted: forgot to add `from functools import lru_cache` import. Fixing.
```

### V — Verify (Run checks)

Run the appropriate verification:

1. **Lint check**: `ruff check <file>` (Python) or `biome check <file>` (TypeScript)
2. **Type check**: `mypy <file>` if applicable
3. **Unit tests**: `pytest <relevant_test_file> -v`
4. **Quick smoke test**: If it's an API change, hit the endpoint

Report results:
```
VERIFY:
- ruff: clean
- pytest tests/test_compiler.py: 12 passed, 0 failed
- Change is confirmed working.
```

If verification fails:
- Do NOT move to the next change
- Start a new RARV cycle to fix the failure
- The fix cycle should be: Reason about the failure -> Act to fix -> Reflect on the fix -> Verify again

## Cycle Discipline

### One RARV per Logical Change

Do NOT batch multiple changes into one cycle. If you need to:
1. Add a model field
2. Update the repository
3. Update the API route

That is THREE RARV cycles, not one.

### When to Break the Cycle

You may compress RARV for trivial changes (fixing a typo, adding an import) but NEVER skip the Verify phase. Even trivial changes can break things.

### Nesting

RARV cycles can nest. If the Verify phase reveals a bug, start a new inner RARV cycle to fix it. Return to the outer cycle once the inner one completes.

```
RARV (outer - add feature)
  R: Adding cache to compiler
  A: [make change]
  R: Looks good
  V: Test fails — KeyError on empty section_id
    RARV (inner - fix bug)
      R: Need to handle None section_id in cache key
      A: Add guard clause
      R: Guard returns uncached result for None — correct behavior
      V: Tests pass
  V (outer): All tests pass now. Feature complete.
```

## Anti-Patterns

- **Act without Reason**: Making changes "to see what happens" — this is debugging by mutation, not engineering
- **Skip Reflect**: Assuming your code is correct without re-reading it
- **Skip Verify**: "It should work" is not verification. Run the tests.
- **Mega-Act**: Making 10 changes in one Act phase, then trying to debug which one broke things
- **Verify-only-at-end**: Running tests only after 20 changes — if something broke, you don't know which change caused it
