#!/bin/bash
# SessionStart hook: First-run detection, connectivity check, context injection
# Runs on every session start. Detects if setup has been completed.

STATE_DIR="$HOME/.gs-orchestrator"
STATE_FILE="$STATE_DIR/state.json"
OBSERVATIONS_FILE="$STATE_DIR/observations.jsonl"

# Ensure state directory exists
mkdir -p "$STATE_DIR"

# Check if first run (no state file)
if [ ! -f "$STATE_FILE" ]; then
    # First run — prompt for setup
    cat <<'CONTEXT'
{
  "additionalContext": "GS Orchestrator plugin loaded (first run). Run /gs:setup to configure SSH access, database connection, and environment variables. Until setup is complete, some features (DB queries, Lightsail access) will not work."
}
CONTEXT
    exit 0
fi

# State file exists — check connectivity
STATUS_PARTS=""

# Check SSH connectivity (non-blocking, 3s timeout)
if ssh -o ConnectTimeout=3 -o BatchMode=yes gs-production-v2 "echo ok" >/dev/null 2>&1; then
    STATUS_PARTS="SSH:ok"
else
    STATUS_PARTS="SSH:down"
fi

# Check if SSH tunnel for DB is running on port 5434
if lsof -i :5434 >/dev/null 2>&1; then
    STATUS_PARTS="$STATUS_PARTS DB-tunnel:active"
else
    # Try to start the tunnel
    ssh -f -N -L 5434:172.18.0.12:5432 gs-production-v2 2>/dev/null
    if lsof -i :5434 >/dev/null 2>&1; then
        STATUS_PARTS="$STATUS_PARTS DB-tunnel:started"
    else
        STATUS_PARTS="$STATUS_PARTS DB-tunnel:failed"
    fi
fi

# Read project context from state
PROJECT=$(python3 -c "
import json, sys
try:
    with open('$STATE_FILE') as f:
        state = json.load(f)
    print(state.get('current_project', ''))
except:
    print('')
" 2>/dev/null)

# Emit context
cat <<CONTEXT
{
  "additionalContext": "GS Orchestrator loaded. Infrastructure: $STATUS_PARTS. Project: ${PROJECT:-none}. Use /gs:status for details."
}
CONTEXT

exit 0
