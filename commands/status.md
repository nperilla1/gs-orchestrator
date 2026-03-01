---
name: gs:status
description: "Show project, agent, and infrastructure connectivity status for the GrantSmiths orchestrator."
---

# /gs:status -- System Status Dashboard

You are reporting the current state of the GrantSmiths orchestrator environment. Gather information from multiple sources and present a clear status dashboard.

## Information to Gather

Run these checks and compile the results:

### 1. SSH Connectivity

```bash
ssh -o ConnectTimeout=3 -o BatchMode=yes gs-production-v2 "echo ok" 2>&1
```

Report: Connected / Unreachable / Timeout

### 2. DB Tunnel Status

```bash
lsof -i :5434 2>/dev/null | grep LISTEN
```

Report: Active (PID) / Inactive

If inactive, offer to start it:
```bash
ssh -f -N -L 5434:172.18.0.12:5432 gs-production-v2
```

### 3. Database Connectivity

If tunnel is active:
```bash
ssh gs-production-v2 "docker exec gs-backend psql -U n8n -d gs_unified -c 'SELECT count(*) FROM information_schema.schemata WHERE schema_name NOT LIKE '\''pg_%'\'' AND schema_name != '\''information_schema'\'''" 2>/dev/null
```

Report: Connected (N schemas) / Unreachable

### 4. Current Project

Detect from cwd:
```bash
# Check for pyproject.toml or package.json
ls pyproject.toml package.json 2>/dev/null
# Read project name
python3 -c "
import tomllib
with open('pyproject.toml', 'rb') as f:
    print(tomllib.load(f)['project']['name'])
" 2>/dev/null || node -e "console.log(require('./package.json').name)" 2>/dev/null
```

Report: Project name and path, or "Not in a project directory"

### 5. Available Agents

List the 13 agents from the plugin:

| Agent | Model | Focus |
|-------|-------|-------|
| code-reviewer | opus | 5-domain parallel code review (read-only) |
| devils-advocate | opus | Adversarial review with 0-100 scoring |
| debugger | sonnet | 4-phase root cause analysis |
| researcher | sonnet | Codebase, web, and Lightsail exploration |
| db-analyst | sonnet | Read-only DB queries across 18 schemas |
| db-reviewer | sonnet | PostgreSQL anti-pattern detection |
| security-sentinel | sonnet | OWASP-aligned security scanning |
| knowledge-curator | sonnet | Knowledge base maintenance |
| code-simplifier | sonnet | Simplify recently modified code |
| test-runner | haiku | Test execution and health checks |
| docker-ops | haiku | Container management on Lightsail |
| session-distiller | haiku | Compress session learnings to memory |
| pr-shepherd | haiku | CI monitoring and PR advancement |

### 6. Active Hooks

Report which hooks are configured:
- SessionStart: bootstrap.sh
- UserPromptSubmit: skill-router.sh
- PreToolUse: protect-files.sh (Edit/Write + Bash)
- PostToolUse: post-write-validate.sh + auto-format.sh (async)
- Stop: completion-gate.sh
- PreCompact: compact-context.sh

Note if completion gate is active (`.gs-completion-gate` file exists in project root).

### 7. Recent Instincts

```bash
tail -5 ~/.gs-orchestrator/instincts.jsonl 2>/dev/null
```

Report the 5 most recent instincts, or "No instincts recorded yet" if the file does not exist.

### 8. Git Status

```bash
git branch --show-current 2>/dev/null
git status --porcelain 2>/dev/null | head -10
git log --oneline -3 2>/dev/null
```

Report: branch name, number of modified/untracked files, last 3 commits.

### 9. Test Status

Run a quick test check (no full suite):
```bash
python3 -m pytest tests/ --co -q 2>/dev/null | tail -1
```

Report: N tests collected, or "No tests found"

## Output Format

```
GS Orchestrator Status
======================

Infrastructure
  SSH:          [Connected / Unreachable]
  DB Tunnel:    [Active on :5434 / Inactive]
  Database:     [Connected (18 schemas) / Unreachable]

Project
  Name:         [project name or "none"]
  Path:         [absolute path]
  Branch:       [git branch]
  Modified:     [N files]
  Tests:        [N collected]

Agents:         13 available (2 opus, 7 sonnet, 4 haiku)

Hooks:          6 active
  Completion Gate: [active / inactive]

Instincts:      [N recorded]
  Latest:       [most recent instinct summary]

Recent Commits:
  - [commit 1]
  - [commit 2]
  - [commit 3]
```
