# Code Review Rubric -- 5-Severity-Tier Scoring

Structured rubric for evaluating code quality. Each finding is classified by severity and includes actionable remediation.

## Severity Tiers

### Tier 1: Critical (Must Fix)

Issues that cause security vulnerabilities, data loss, or system crashes. These BLOCK the PR.

**Examples:**
- SQL injection (unsanitized user input in queries)
- Hardcoded credentials or API keys
- Data loss (writes without commits, silent drops)
- Unhandled exceptions that crash the service
- Race conditions that corrupt data
- Missing authentication/authorization checks on endpoints

**Finding format:**
```
[CRITICAL] <file>:<line> -- <description>
  Impact: <what happens if this ships>
  Fix: <exact code change needed>
```

### Tier 2: High (Should Fix)

Bugs, performance issues, or logic errors that will cause problems in production. These should be fixed before merge.

**Examples:**
- Off-by-one errors
- Missing error handling for external service calls
- N+1 query patterns
- Missing database indexes on frequently queried columns
- Incorrect type annotations that hide bugs
- Missing input validation on API endpoints
- Unbounded queries (no LIMIT)

**Finding format:**
```
[HIGH] <file>:<line> -- <description>
  Impact: <likely production impact>
  Fix: <suggested approach>
```

### Tier 3: Medium (Recommended)

Code quality issues that affect maintainability but do not cause immediate bugs. Fix when convenient.

**Examples:**
- Poor naming (variables, functions, classes)
- Missing docstrings on public APIs
- Duplicated code that should be extracted
- Overly complex functions (cyclomatic complexity > 10)
- Missing type annotations
- Inconsistent error handling patterns
- Magic numbers without named constants

**Finding format:**
```
[MEDIUM] <file>:<line> -- <description>
  Suggestion: <how to improve>
```

### Tier 4: Low (Nice to Have)

Style and formatting issues. Fix during cleanup passes, not during feature work.

**Examples:**
- Import ordering
- Line length violations
- Inconsistent string quoting
- Trailing whitespace
- Missing blank lines between sections
- Minor naming convention deviations

**Finding format:**
```
[LOW] <file>:<line> -- <description>
  Note: <brief suggestion>
```

### Tier 5: Info (Observations)

Non-actionable observations, questions, or positive feedback.

**Examples:**
- "This pattern is clever -- consider documenting it"
- "Question: why was this approach chosen over X?"
- "Good use of the repository pattern here"
- "This test coverage is thorough"

**Finding format:**
```
[INFO] <file>:<line> -- <observation or question>
```

## Review Checklist

Run through these categories for every code review:

### Correctness
- [ ] Does the code do what it claims to do?
- [ ] Are edge cases handled (empty input, null, max values)?
- [ ] Are error paths tested?
- [ ] Do database queries return the expected results?

### Security
- [ ] Are all inputs validated and sanitized?
- [ ] Are SQL queries parameterized (no string interpolation)?
- [ ] Are credentials stored in env vars, not code?
- [ ] Are API endpoints authenticated and authorized?
- [ ] Is sensitive data logged or exposed in error messages?

### Performance
- [ ] Are there N+1 query patterns?
- [ ] Are large datasets paginated?
- [ ] Are expensive computations cached where appropriate?
- [ ] Are database queries using indexes?

### Maintainability
- [ ] Is the code readable without extensive comments?
- [ ] Are functions focused (single responsibility)?
- [ ] Are magic numbers replaced with named constants?
- [ ] Is there duplicated code that should be extracted?

### Testing
- [ ] Are there tests for the new/changed code?
- [ ] Do tests cover both happy path and error cases?
- [ ] Are tests independent (not relying on external state)?
- [ ] Is the test naming clear about what is being tested?

### GS-Specific
- [ ] Are JSONB values serialized with json.dumps() before DB writes?
- [ ] Are pgvector embeddings parsed with json.loads() after DB reads?
- [ ] Are NULL parameters typed with CAST in asyncpg queries?
- [ ] Is get_transaction() used for writes (not get_connection())?
- [ ] Are Pydantic models including all pass-through fields?

## Scoring

Aggregate findings into a review score:

| Score | Verdict | Criteria |
|-------|---------|----------|
| 0 Critical, 0 High | APPROVE | Ship it |
| 0 Critical, 1-3 High | REQUEST CHANGES | Fix the highs, then approve |
| 1+ Critical | REQUEST CHANGES | Must fix before any discussion of merge |
| 5+ Medium | COMMENT | No blockers, but suggest cleanup pass |

## Review Report Template

```
## Code Review: [PR title or description]

### Summary
[1-2 sentence overview of the changes and overall quality]

### Findings

[CRITICAL findings first, then HIGH, MEDIUM, LOW, INFO]

### Verdict: [APPROVE / REQUEST CHANGES / COMMENT]

### Statistics
- Files reviewed: N
- Critical: N
- High: N
- Medium: N
- Low: N
- Info: N
```
