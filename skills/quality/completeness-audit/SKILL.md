---
name: completeness-audit
description: 12-category verification checklist for any plan or implementation. Scores each category 0-10 across core requirements met, edge cases handled, error handling comprehensive, security vetted, performance acceptable, tests adequate, data model correct, API contracts honored, UI/UX considered, deployment ready, monitoring/logging in place, and documentation updated. Flags any category scoring below 5 as a blocker. Produces a total completeness score out of 120 with SHIP/REVISE/BLOCK verdict. Use after completing a feature, plan, or implementation to verify nothing was missed before shipping.
allowed-tools: Read, Grep, Glob, Bash
---

# Completeness Audit

You are performing a systematic completeness audit on a plan or implementation. This is a 12-category verification that catches what developers forget.

## Target
$ARGUMENTS
(Specify the feature, plan, PR, or implementation to audit)

## Audit Process

For each category, investigate the codebase and score 0-10. Provide specific evidence for your score.

### Category 1: Core Requirements Met (0-10)
- List the requirements (from plan, spec, issue, or PR description)
- Check each requirement against the implementation
- Are ALL stated requirements implemented?
- Is anything partially implemented?
- Score 10 = all requirements fully met

### Category 2: Edge Cases Handled (0-10)
- Empty/null inputs
- Boundary values (0, max int, empty string)
- Concurrent access
- Network failures mid-operation
- User provides unexpected input types
- Score 10 = all foreseeable edge cases handled

### Category 3: Error Handling Comprehensive (0-10)
- Every external call has try/catch or equivalent
- Error messages are user-friendly AND debug-useful
- Errors propagate correctly (not swallowed silently)
- Async errors are caught
- Partial failure states are handled (rollback or compensate)
- Score 10 = errors handled at every level

### Category 4: Security Vetted (0-10)
- Input validation on all user-supplied data
- No SQL injection, XSS, CSRF, or command injection vectors
- Authentication/authorization checked on all endpoints
- Secrets not in source code
- Sensitive data not in logs
- Score 10 = no security concerns

### Category 5: Performance Acceptable (0-10)
- No N+1 query patterns
- Queries use indexes
- Payloads are reasonably sized
- No blocking I/O in async context
- Pagination for large result sets
- Score 10 = performs well under expected load

### Category 6: Tests Adequate (0-10)
- Unit tests for core logic
- Integration tests for API endpoints
- Edge case tests
- Error path tests
- Test naming describes behavior
- Score 10 = high confidence tests prevent regressions

### Category 7: Data Model Correct (0-10)
- Schema matches the domain model
- Foreign keys and constraints in place
- Indexes on queried columns
- Migrations are reversible
- No data integrity gaps
- Score 10 = data model is sound

### Category 8: API Contracts Honored (0-10)
- Request/response shapes match docs
- Status codes are correct
- Error response format is consistent
- Backward compatibility maintained
- Content types are correct
- Score 10 = API is contract-compliant

### Category 9: UI/UX Considered (0-10)
- Loading states shown
- Error states shown with user-friendly messages
- Empty states handled
- Responsive at key breakpoints
- Accessible (keyboard, screen reader, contrast)
- Score 10 = polished user experience (N/A for backend-only)

### Category 10: Deployment Ready (0-10)
- Environment variables documented
- Database migrations tested
- No hardcoded localhost URLs
- Health check endpoint exists
- Graceful shutdown handled
- Score 10 = deployable without manual steps

### Category 11: Monitoring/Logging in Place (0-10)
- Key operations logged with structured data
- Errors logged with context (not just stack trace)
- Metrics for critical paths (latency, error rate)
- Alerts configured for failures
- No sensitive data in logs
- Score 10 = observable in production

### Category 12: Documentation Updated (0-10)
- README reflects current state
- API docs updated for new endpoints
- CLAUDE.md updated if architecture changed
- Inline comments explain WHY, not WHAT
- Migration notes for breaking changes
- Score 10 = someone new could understand this

## Output Format

```
## Completeness Audit Report

### Target: [what was audited]

### Scores
| # | Category | Score | Status | Evidence |
|---|----------|-------|--------|----------|
| 1 | Core Requirements | X/10 | OK/WARN/BLOCK | ... |
| 2 | Edge Cases | X/10 | OK/WARN/BLOCK | ... |
| ... | ... | ... | ... | ... |
| 12 | Documentation | X/10 | OK/WARN/BLOCK | ... |

### Total: XX/120

### Blockers (categories below 5)
[List any category that scored below 5 -- these MUST be fixed]

### Warnings (categories 5-7)
[List categories that should be improved]

### Verdict: SHIP / REVISE / BLOCK
```

**Verdicts:**
- **SHIP** (96+, no blockers): Ready for production
- **REVISE** (72-95, no blockers): Fix warnings, then ship
- **BLOCK** (<72 or any blocker): Fix blockers before proceeding
