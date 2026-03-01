---
name: code-review
description: "Multi-angle code review with 5 structured passes covering correctness, security, performance, maintainability, and GS-domain patterns. Triggers when reviewing code, checking code quality, before merging, when the user says 'review this', 'check my code', or 'is this good'."
version: "1.0"
---

# Code Review Skill

You are performing a structured code review. Run all 5 passes. Do NOT skip any pass — bugs hide in the passes you think are unnecessary.

## When to Use

- After completing a feature (Step 6 of **feature-dev** skill)
- When the user asks "review this", "check my code", "is this good"
- Before merging a branch or creating a PR
- When reviewing someone else's code or PR diff

## The 5 Review Passes

### Pass 1: Correctness

Does the code do what it claims to do?

Check:
- [ ] Functions return the expected types
- [ ] All code paths are handled (if/elif/else — is there a missing branch?)
- [ ] Loops terminate (no infinite loops, correct exit conditions)
- [ ] Null/None handling (what happens when optional values are absent?)
- [ ] Off-by-one errors (especially in slicing, pagination, indexing)
- [ ] Async correctness (all async functions awaited, no sync calls in async context)
- [ ] Error propagation (exceptions caught at the right level, not swallowed silently)
- [ ] Edge cases (empty lists, empty strings, zero values, max-size inputs)

For each issue found:
```
CORRECTNESS [severity]: [file:line] [description]
  Suggestion: [how to fix]
```

Severity: CRITICAL (wrong results), WARNING (could fail in edge cases), INFO (minor concern).

### Pass 2: Security

OWASP top 10 + GS-specific security patterns.

Check:
- [ ] SQL injection — all queries use parameterized statements (`:param` not f-strings)
- [ ] Input validation — all user input validated via Pydantic before use
- [ ] Authentication — all endpoints have auth middleware
- [ ] Authorization — users can only access their own data (tenant isolation)
- [ ] Secrets — no API keys, passwords, or tokens in code (should be in env/config)
- [ ] Path traversal — file paths validated, no user-controlled paths
- [ ] CORS — appropriate origins configured
- [ ] Rate limiting — destructive operations are rate-limited
- [ ] Data exposure — responses don't leak internal IDs, stack traces, or DB structure

GS-specific:
- [ ] Cross-organization data isolation (org_id filtering on all queries)
- [ ] Prompt injection resistance (user inputs in prompts are sandboxed)
- [ ] Evidence chain integrity (evidence IDs cannot be spoofed)

For each issue:
```
SECURITY [severity]: [file:line] [description]
  Risk: [what could an attacker do?]
  Fix: [how to fix]
```

Severity: CRITICAL (exploitable now), HIGH (exploitable with effort), MEDIUM (defense-in-depth).

### Pass 3: Performance

Identify bottlenecks and unnecessary work.

Check:
- [ ] N+1 queries — loading related data in a loop instead of a JOIN or batch query
- [ ] Missing indexes — filtering/sorting on columns without indexes
- [ ] Unbounded queries — `SELECT *` without LIMIT, fetching entire tables
- [ ] Unnecessary serialization — converting to/from JSON when not needed
- [ ] Blocking I/O in async context — sync HTTP calls, file reads without async
- [ ] Missing caching — repeated identical computations or queries
- [ ] Large payloads — API responses returning more data than the client needs
- [ ] O(n^2) or worse — nested loops over growing datasets

For each issue:
```
PERFORMANCE [severity]: [file:line] [description]
  Impact: [estimated effect at scale — e.g., "100ms per request at 1000 orgs"]
  Fix: [how to fix]
```

Severity: CRITICAL (will cause outages), HIGH (noticeable latency), MEDIUM (suboptimal).

### Pass 4: Maintainability

Can another developer (or future-you) understand and modify this code?

Check:
- [ ] Naming — variables, functions, classes have descriptive names
- [ ] Function length — functions under 30 lines? If longer, should they be split?
- [ ] Cyclomatic complexity — deeply nested if/else? Consider early returns or extraction
- [ ] DRY — duplicated logic that should be extracted into a shared function
- [ ] Coupling — does this module depend on internal details of another module?
- [ ] Type annotations — all function signatures have type hints
- [ ] Error messages — exceptions have descriptive messages, not just bare `raise`
- [ ] Comments — complex logic has explanatory comments; obvious code doesn't have redundant comments
- [ ] Module organization — is the code in the right file/package?
- [ ] Test coverage — new code has corresponding tests

For each issue:
```
MAINTAINABILITY [severity]: [file:line] [description]
  Suggestion: [how to improve]
```

Severity: HIGH (will cause confusion/bugs), MEDIUM (suboptimal), LOW (nitpick).

### Pass 5: GS-Domain Patterns

Does the code follow GS platform conventions and domain rules?

Check:
- [ ] **Evidence chain of custody** — evidence is gathered, never invented. Writer uses ONLY provided evidence. IDs trace back to sources.
- [ ] **Prompt handling** — system prompts loaded from DB with file fallback. ADAPT templates processed correctly. User notes have highest priority.
- [ ] **Database patterns** — uses schema-scoped tables (`schema="writer"`). JSONB validated via Pydantic before writes. `get_transaction()` for writes, `get_connection()` for reads. `json.dumps()` before `CAST(:param AS jsonb)`.
- [ ] **Grant/Project hierarchy** — grant instance (per NOFO) vs project instance (per applicant) distinction maintained. No cross-contamination.
- [ ] **Model routing** — respects model selection (user-controlled, not auto-routed).
- [ ] **Repository pattern** — data access through repositories, not direct DB calls in services/routes.
- [ ] **Config pattern** — Pydantic Settings with `env_file=("../.env.shared", ".env")`.
- [ ] **Error handling** — structured errors with proper HTTP codes, not generic 500s.
- [ ] **Logging** — uses structlog, not print statements. Includes relevant context.

For each issue:
```
GS-DOMAIN [severity]: [file:line] [description]
  Convention: [what the GS pattern requires]
  Fix: [how to align]
```

## Output Format

After completing all 5 passes, produce a summary:

```
CODE REVIEW SUMMARY

Files reviewed: [list]
Lines of code: [approximate]

Findings by severity:
  CRITICAL: N
  HIGH: N
  MEDIUM: N
  LOW/INFO: N

Pass 1 (Correctness): [N findings — brief summary]
Pass 2 (Security): [N findings — brief summary]
Pass 3 (Performance): [N findings — brief summary]
Pass 4 (Maintainability): [N findings — brief summary]
Pass 5 (GS-Domain): [N findings — brief summary]

Top 3 issues to fix before merging:
1. [most important]
2. [second most important]
3. [third most important]

Verdict: APPROVE / APPROVE WITH CHANGES / REQUEST CHANGES
```

## After Review

If issues were found:
1. Fix CRITICAL and HIGH issues using the **rarv-loop** skill
2. Re-run affected tests
3. Re-run the linter
4. Note MEDIUM/LOW issues for future cleanup (do not block on them)

If no issues found:
1. Proceed to the **finishing-branch** skill
