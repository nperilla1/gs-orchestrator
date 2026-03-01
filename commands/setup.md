---
name: gs:setup
description: "First-time configuration wizard. Establishes SSH connectivity, database access, SSH tunnels, and environment variables for the GrantSmiths orchestrator."
---

# /gs:setup -- First-Time Configuration

You are running the GrantSmiths orchestrator setup wizard. Walk the user through each step sequentially. Do not skip steps. Report success/failure clearly at each stage.

## Step 1: Check SSH Connectivity

```bash
ssh -o ConnectTimeout=5 -o BatchMode=yes gs-production-v2 "echo 'SSH OK'"
```

- If this succeeds, report: "SSH to gs-production-v2 (52.72.246.186) is working."
- If this fails, troubleshoot:
  - Check `~/.ssh/config` for the `gs-production-v2` host entry
  - Check `~/.ssh/id_ed25519` exists and has correct permissions (600)
  - Suggest: `ssh -vvv gs-production-v2 "echo test"` for debug output
  - Do NOT proceed until SSH works.

## Step 2: Retrieve Database Password

```bash
ssh gs-production-v2 "grep DB_POSTGRESDB_PASSWORD /home/ubuntu/n8n/.env | cut -d= -f2"
```

- Store the password for use in the next steps
- If the grep fails, ask the user to provide the password manually
- Never display the full password in output -- show only the first 4 characters

## Step 3: Write Configuration

Create `~/.gs-orchestrator/state.json`:

```json
{
  "setup_completed": true,
  "setup_date": "<ISO 8601 timestamp>",
  "ssh_host": "gs-production-v2",
  "db_host": "172.18.0.12",
  "db_port": 5432,
  "db_name": "gs_unified",
  "db_user": "n8n",
  "tunnel_local_port": 5434,
  "current_project": null,
  "companion_plugins": {}
}
```

Construct and export the DB URL:

```bash
export GS_DB_URL="postgresql://n8n:<password>@localhost:5434/gs_unified"
```

Write to `~/.gs-orchestrator/.env`:

```
GS_DB_URL=postgresql://n8n:<password>@localhost:5434/gs_unified
GS_DB_PASSWORD=<password>
```

## Step 4: Start SSH Tunnel for Database

```bash
# Kill any existing tunnel on port 5434
lsof -ti :5434 | xargs kill 2>/dev/null

# Start new tunnel in background
ssh -f -N -L 5434:172.18.0.12:5432 gs-production-v2

# Verify it is running
lsof -i :5434 | grep LISTEN
```

- Report the tunnel status
- If it fails, check if another process is using port 5434

## Step 5: Verify Database Connection

```bash
PGPASSWORD="<password>" psql -h localhost -p 5434 -U n8n -d gs_unified -c "SELECT count(*) as schemas FROM information_schema.schemata WHERE schema_name NOT IN ('information_schema', 'pg_catalog', 'pg_toast');"
```

- Expected: 18 schemas
- If psql is not installed locally, try via SSH:
  ```bash
  ssh gs-production-v2 "docker exec gs-backend psql -U n8n -d gs_unified -c 'SELECT 1'"
  ```
- Report the schema count and confirm connectivity

## Step 6: Check Companion Plugins

Check if recommended companion plugins are available:

```bash
# Check for superpowers plugin
claude plugin list 2>/dev/null | grep -i superpowers

# Check for coderabbit plugin
claude plugin list 2>/dev/null | grep -i coderabbit
```

Update state.json with findings:
```json
{
  "companion_plugins": {
    "superpowers": true/false,
    "coderabbit": true/false
  }
}
```

Report which are installed and which are recommended.

## Step 7: Mark Setup Complete

Update `~/.gs-orchestrator/state.json` with `"setup_completed": true`.

Print a summary:

```
GS Orchestrator Setup Complete
------------------------------
SSH:        Connected to gs-production-v2 (52.72.246.186)
DB Tunnel:  localhost:5434 -> 172.18.0.12:5432
Database:   gs_unified (18 schemas, 230+ tables)
Plugins:    superpowers [installed/missing], coderabbit [installed/missing]

Ready to use. Try:
  /gs:status   -- Check current state
  /gs:start    -- Begin autonomous task execution
```

## Error Recovery

If any step fails:
1. Report which step failed and why
2. Save partial progress to state.json with `"setup_completed": false`
3. Tell the user they can re-run `/gs:setup` to resume from the failed step
4. Do NOT mark setup as complete if any critical step (1, 2, 4, 5) failed
