# Security Audit Rubric -- OWASP-Aligned Scoring

Structured rubric for security auditing. Categories align with OWASP Top 10 plus GS-specific concerns. Score 0-100.

## Scoring Overview

| Score | Rating | Meaning |
|-------|--------|---------|
| 90-100 | Excellent | No critical or high findings. Minor improvements only. |
| 70-89 | Good | No critical findings. Some high/medium issues to address. |
| 50-69 | Needs Work | High-severity issues present. Must fix before production. |
| 30-49 | Poor | Critical vulnerabilities found. Significant remediation needed. |
| 0-29 | Failing | Multiple critical vulnerabilities. Unsafe for any environment. |

## Categories

### 1. Injection (20 points)

**SQL Injection**
- [ ] All database queries use parameterized statements (not string interpolation)
- [ ] Dynamic query construction uses query builders, not f-strings
- [ ] User-provided sort/filter fields are validated against an allowlist
- [ ] LIKE patterns are properly escaped

**Command Injection**
- [ ] Shell commands do not include unsanitized user input
- [ ] subprocess calls use list arguments, not shell=True
- [ ] File paths are validated before use

**XSS (Cross-Site Scripting)**
- [ ] User input is escaped before rendering in HTML
- [ ] Content-Security-Policy headers are configured
- [ ] React raw HTML insertion is avoided; when necessary, content is sanitized via DOMPurify

**Scoring:**
- 20: No injection vulnerabilities
- 15: Minor issues (e.g., missing escaping in non-user-facing context)
- 10: Moderate issues (e.g., dynamic queries without full parameterization)
- 5: High-severity injection vectors present
- 0: Critical SQL injection or command injection in user-facing endpoints

### 2. Authentication (15 points)

- [ ] JWT tokens are validated on every protected endpoint
- [ ] Token expiration is enforced
- [ ] Passwords are hashed with bcrypt (not MD5, SHA-1, or plaintext)
- [ ] Login endpoints are rate-limited
- [ ] Session tokens are invalidated on logout
- [ ] Password reset flows do not leak user existence

**GS-Specific:**
- [ ] JWT uses HS256 with a strong secret from env vars
- [ ] The gs-auth shared library is used consistently
- [ ] API keys are validated against the auth schema

**Scoring:**
- 15: Robust authentication with all checks
- 10: Authentication present but missing some checks
- 5: Authentication bypassable or misconfigured
- 0: No authentication on protected endpoints

### 3. Authorization (15 points)

- [ ] RBAC is enforced at the API layer (not just UI)
- [ ] Users cannot access other users' data (IDOR prevention)
- [ ] Admin endpoints require admin role verification
- [ ] Database queries include tenant/user ID filters
- [ ] File upload/download endpoints verify ownership

**GS-Specific:**
- [ ] Organization data is scoped to the requesting user's org
- [ ] Grant/project instances are accessible only to authorized users
- [ ] System prompts cannot be modified by non-admin users

**Scoring:**
- 15: Complete authorization model with no bypass vectors
- 10: Authorization present but inconsistent
- 5: Authorization easily bypassed (e.g., IDOR)
- 0: No authorization checks

### 4. Data Exposure (15 points)

- [ ] Sensitive data (passwords, tokens, keys) is never logged
- [ ] Error messages do not leak internal details (stack traces, SQL, paths)
- [ ] API responses do not include unnecessary fields (e.g., password hashes)
- [ ] Secrets are stored in environment variables, not in code
- [ ] Database connection strings are not exposed in logs or responses

**GS-Specific:**
- [ ] System prompts (489KB of domain expertise) are not exposed to unauthorized users
- [ ] Organization CRM data is not leaked across tenants
- [ ] Embedding vectors are not returned in API responses unless needed

**Scoring:**
- 15: No data exposure vectors
- 10: Minor exposure (e.g., verbose error messages in non-production)
- 5: Sensitive data logged or returned in API responses
- 0: Credentials or PII exposed in logs, responses, or code

### 5. Security Misconfiguration (10 points)

- [ ] CORS is configured with specific origins (not `*`)
- [ ] HTTP security headers are present (HSTS, X-Frame-Options, etc.)
- [ ] Debug mode is disabled in production
- [ ] Default credentials are changed
- [ ] Unnecessary ports/services are not exposed

**GS-Specific:**
- [ ] Caddy reverse proxy properly restricts path access
- [ ] Docker containers do not run as root
- [ ] SSH access uses key-based auth only

**Scoring:**
- 10: All configurations follow security best practices
- 7: Minor misconfigurations in non-critical areas
- 4: Significant misconfigurations that increase attack surface
- 0: Critical misconfigurations (e.g., debug mode in production)

### 6. Vulnerable Dependencies (10 points)

- [ ] All dependencies have pinned versions
- [ ] No known CVEs in current dependency versions
- [ ] Dependencies are from reputable sources
- [ ] `pip audit` or `npm audit` reports no critical vulnerabilities

**Scoring:**
- 10: All dependencies up-to-date, no known vulnerabilities
- 7: Minor vulnerabilities in non-critical dependencies
- 4: Known vulnerabilities in direct dependencies
- 0: Critical CVEs in actively used dependencies

### 7. Logging and Monitoring (10 points)

- [ ] Authentication events are logged (login, logout, failed attempts)
- [ ] Authorization failures are logged
- [ ] Database errors are logged with context
- [ ] Logs include request IDs for traceability
- [ ] Sensitive data is redacted from logs

**Scoring:**
- 10: Comprehensive logging with redaction
- 7: Good logging coverage, minor gaps
- 4: Minimal logging, hard to diagnose issues
- 0: No meaningful logging

### 8. Input Validation (5 points)

- [ ] All API inputs are validated with Pydantic models
- [ ] File uploads validate type, size, and content
- [ ] Numeric inputs have range checks
- [ ] String inputs have length limits
- [ ] Enum fields validate against allowed values

**Scoring:**
- 5: Complete input validation
- 3: Most inputs validated, some gaps
- 1: Minimal validation
- 0: No input validation

## Audit Report Template

```
## Security Audit: [Project/Component Name]

### Overall Score: [N/100] -- [Rating]

### Category Scores
| Category | Score | Max | Notes |
|----------|-------|-----|-------|
| Injection | | 20 | |
| Authentication | | 15 | |
| Authorization | | 15 | |
| Data Exposure | | 15 | |
| Misconfiguration | | 10 | |
| Dependencies | | 10 | |
| Logging | | 10 | |
| Input Validation | | 5 | |

### Critical Findings
[List any critical findings that must be fixed immediately]

### High Findings
[List high-severity findings]

### Recommendations
[Prioritized list of improvements]

### Positive Observations
[What the project does well from a security perspective]
```
