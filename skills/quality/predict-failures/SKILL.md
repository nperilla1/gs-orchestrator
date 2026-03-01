---
name: predict-failures
description: Perform predictive failure analysis on a codebase before deployment. Systematically examines code for potential production failures that testing might miss across 8 categories -- race conditions and concurrency, edge cases and boundary conditions, error handling gaps, security vulnerabilities (SQL injection, XSS, path traversal), data integrity risks, scaling and performance (N+1 queries, memory leaks), integration failures (timeouts, missing retries), and configuration/deployment issues. Outputs findings with CRITICAL/HIGH/MEDIUM/LOW severity ratings and recommended fixes. Use after implementation is complete but before deploying to production.
allowed-tools: Read, Grep, Glob, Bash, Task
---

# Predictive Failure Analysis

You are performing a predictive failure analysis. This goes beyond testing -- you're looking for issues that COULD happen in production but aren't covered by existing tests.

## Target
Analyze: $ARGUMENTS
(If no specific target given, analyze the most recently modified files in the project)

## Analysis Categories

Work through each category systematically:

### 1. Race Conditions & Concurrency
- Shared mutable state without locks
- Database operations that assume sequential execution
- File operations that could conflict
- Cache invalidation timing issues

### 2. Edge Cases & Boundary Conditions
- Empty collections, null/None values, zero-length strings
- Integer overflow, floating point precision
- Unicode/encoding issues
- Maximum payload sizes
- Timezone handling

### 3. Error Handling Gaps
- Unhandled exceptions in async code
- Missing try/catch around external calls
- Error messages that leak internal details
- Silently swallowed errors (bare except, empty catch)

### 4. Security Vulnerabilities
- SQL injection vectors
- XSS in rendered output
- Command injection via user input
- Path traversal in file operations
- Sensitive data in logs or error messages
- Missing authentication/authorization checks

### 5. Data Integrity Risks
- Missing database constraints
- Orphaned records possible
- Inconsistent state between related tables
- Missing cascade deletes/updates
- Data loss on partial failures

### 6. Scaling & Performance
- N+1 query patterns
- Unbounded queries (missing LIMIT)
- Memory leaks (growing caches, unclosed connections)
- Missing indexes on filtered columns
- Blocking I/O in async context

### 7. Integration Failures
- External API timeout handling
- Missing retry logic for transient failures
- Hardcoded URLs or credentials
- Missing circuit breakers
- Version compatibility assumptions

### 8. Configuration & Deployment
- Missing environment variables
- Default values that are dangerous in production
- Secrets in source code
- Missing health checks
- No graceful shutdown handling

## Output Format

For each issue found:
```
[SEVERITY: CRITICAL/HIGH/MEDIUM/LOW]
Category: <category>
Location: <file:line>
Issue: <description>
Impact: <what could go wrong>
Fix: <recommended fix>
```

Summarize with counts per severity and top 5 most critical issues to fix first.
