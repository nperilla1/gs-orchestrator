---
name: preflight
description: Infrastructure connectivity preflight check to run at the start of every session before doing real work. Verifies database connectivity and table count, Docker container health, API key availability (OpenAI, Anthropic, Cohere), test suite discovery, MCP tool connectivity, and disk/memory usage. Outputs a summary table with OK/FAIL/WARN status per check and flags any issues before proceeding with the main task. Essential for sessions that interact with the production Lightsail instance.
allowed-tools: Bash, Read
---

# Preflight Check

Run this at the start of every session to verify infrastructure connectivity before doing real work.

## Steps

1. **Database connectivity**:
   ```bash
   docker exec gs-backend psql -U n8n -d gs_unified -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema NOT IN ('pg_catalog','information_schema')"
   ```
   Expected: 183+ tables.

2. **Docker containers**:
   ```bash
   docker ps --format 'table {{.Names}}\t{{.Status}}' | head -20
   ```
   Verify `gs-backend` is healthy.

3. **API keys** -- check that critical keys are set and non-empty:
   ```bash
   grep -E '^(OPENAI_API_KEY|COHERE_API_KEY|ANTHROPIC_API_KEY)=' ~/n8n/.env | sed 's/=.*/=<set>/'
   ```

4. **Test suite discovery**:
   ```bash
   cd ~/gsbot-platform && python3 -m pytest --co -q 2>&1 | tail -5
   ```
   Expected: 1352+ tests collected.

5. **MCP tools** -- if the session needs Supabase or Airtable MCP, make a simple list call to verify connectivity.

6. **Disk and memory**:
   ```bash
   df -h / | tail -1 && free -h | head -2
   ```

## Output

Report a summary table:

| Check | Status | Detail |
|-------|--------|--------|
| Database | OK/FAIL | table count |
| Docker | OK/FAIL | container count |
| API Keys | OK/FAIL | which are set |
| Tests | OK/FAIL | test count |
| Disk | OK/WARN | % used |
| Memory | OK/WARN | % used |

Flag any issues before proceeding with the main task.
