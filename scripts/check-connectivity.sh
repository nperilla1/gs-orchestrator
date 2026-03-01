#!/bin/bash
# check-connectivity.sh -- Health check for SSH and database connectivity
# Outputs JSON status for consumption by hooks and commands.
# Exit codes: 0 = all healthy, 1 = partial failure, 2 = all down

set -uo pipefail

SSH_HOST="gs-production-v2"
TUNNEL_PORT=5434
DB_DOCKER_IP="172.18.0.12"
DB_PORT=5432

# Initialize status
SSH_STATUS="unknown"
TUNNEL_STATUS="unknown"
DB_STATUS="unknown"
ERRORS=()

# --- Check SSH ---
if ssh -o ConnectTimeout=3 -o BatchMode=yes "$SSH_HOST" "echo ok" >/dev/null 2>&1; then
    SSH_STATUS="connected"
else
    SSH_STATUS="unreachable"
    ERRORS+=("SSH connection to $SSH_HOST failed")
fi

# --- Check DB Tunnel ---
if lsof -i ":$TUNNEL_PORT" >/dev/null 2>&1; then
    TUNNEL_STATUS="active"
    TUNNEL_PID=$(lsof -ti ":$TUNNEL_PORT" 2>/dev/null | head -1)
else
    TUNNEL_STATUS="inactive"

    # Try to start it if SSH is available
    if [ "$SSH_STATUS" = "connected" ]; then
        ssh -f -N -L "$TUNNEL_PORT:$DB_DOCKER_IP:$DB_PORT" "$SSH_HOST" 2>/dev/null
        sleep 1
        if lsof -i ":$TUNNEL_PORT" >/dev/null 2>&1; then
            TUNNEL_STATUS="started"
            TUNNEL_PID=$(lsof -ti ":$TUNNEL_PORT" 2>/dev/null | head -1)
        else
            TUNNEL_STATUS="failed"
            ERRORS+=("Could not start DB tunnel on port $TUNNEL_PORT")
        fi
    else
        ERRORS+=("DB tunnel inactive and SSH unavailable to restart it")
    fi
fi

# --- Check DB Connectivity ---
if [ "$TUNNEL_STATUS" = "active" ] || [ "$TUNNEL_STATUS" = "started" ]; then
    # Try a quick query via SSH (more reliable than local psql which may not be installed)
    DB_RESULT=$(ssh -o ConnectTimeout=3 "$SSH_HOST" "docker exec gs-backend psql -U n8n -d gs_unified -t -c 'SELECT count(*) FROM information_schema.schemata WHERE schema_name NOT LIKE '\''pg_%'\'' AND schema_name != '\''information_schema'\'''" 2>/dev/null | tr -d '[:space:]')

    if [ -n "$DB_RESULT" ] && [ "$DB_RESULT" -gt 0 ] 2>/dev/null; then
        DB_STATUS="connected"
        DB_SCHEMAS="$DB_RESULT"
    else
        DB_STATUS="query_failed"
        DB_SCHEMAS="0"
        ERRORS+=("Database query failed")
    fi
elif [ "$SSH_STATUS" = "connected" ]; then
    # No tunnel but SSH works -- try direct SSH query
    DB_RESULT=$(ssh -o ConnectTimeout=3 "$SSH_HOST" "docker exec gs-backend psql -U n8n -d gs_unified -t -c 'SELECT 1'" 2>/dev/null | tr -d '[:space:]')
    if [ "$DB_RESULT" = "1" ]; then
        DB_STATUS="connected_via_ssh"
        DB_SCHEMAS="unknown"
    else
        DB_STATUS="unreachable"
        DB_SCHEMAS="0"
        ERRORS+=("Database unreachable")
    fi
else
    DB_STATUS="unreachable"
    DB_SCHEMAS="0"
    ERRORS+=("Database unreachable (no SSH, no tunnel)")
fi

# --- Build Error String ---
ERROR_JSON="[]"
if [ ${#ERRORS[@]} -gt 0 ]; then
    ERROR_JSON="["
    FIRST=true
    for err in "${ERRORS[@]}"; do
        if [ "$FIRST" = true ]; then
            FIRST=false
        else
            ERROR_JSON+=","
        fi
        ERROR_JSON+="\"$err\""
    done
    ERROR_JSON+="]"
fi

# --- Output JSON ---
cat << JSONOUT
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "ssh": {
    "host": "$SSH_HOST",
    "status": "$SSH_STATUS"
  },
  "tunnel": {
    "local_port": $TUNNEL_PORT,
    "status": "$TUNNEL_STATUS",
    "pid": ${TUNNEL_PID:-null}
  },
  "database": {
    "status": "$DB_STATUS",
    "schemas": ${DB_SCHEMAS:-0}
  },
  "healthy": $([ "$SSH_STATUS" = "connected" ] && [ "$DB_STATUS" != "unreachable" ] && echo "true" || echo "false"),
  "errors": $ERROR_JSON
}
JSONOUT

# --- Exit Code ---
if [ "$SSH_STATUS" = "connected" ] && [ "$DB_STATUS" = "connected" ] && [ "$TUNNEL_STATUS" != "inactive" ] && [ "$TUNNEL_STATUS" != "failed" ]; then
    exit 0
elif [ "$SSH_STATUS" = "unreachable" ] && [ "$DB_STATUS" = "unreachable" ]; then
    exit 2
else
    exit 1
fi
