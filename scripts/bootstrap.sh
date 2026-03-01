#!/bin/bash
# bootstrap.sh -- First-run setup logic for GS Orchestrator
# Called by the SessionStart hook (hooks/handlers/bootstrap.sh) on first detection.
# Handles SSH key verification, tunnel setup, DB password configuration, and state file creation.

set -euo pipefail

STATE_DIR="$HOME/.gs-orchestrator"
STATE_FILE="$STATE_DIR/state.json"
ENV_FILE="$STATE_DIR/.env"
SSH_HOST="gs-production-v2"
LIGHTSAIL_IP="52.72.246.186"
DB_DOCKER_IP="172.18.0.12"
DB_PORT=5432
TUNNEL_LOCAL_PORT=5434
DB_NAME="gs_unified"
DB_USER="n8n"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; }
log_info() { echo "     $1"; }

echo "==========================================="
echo "  GS Orchestrator -- First-Time Bootstrap  "
echo "==========================================="
echo ""

# --- Step 1: Ensure state directory exists ---
mkdir -p "$STATE_DIR"

# --- Step 2: Check SSH key ---
echo "Step 1/5: Checking SSH configuration..."

SSH_KEY="$HOME/.ssh/id_ed25519"
if [ ! -f "$SSH_KEY" ]; then
    log_fail "SSH key not found at $SSH_KEY"
    log_info "Generate one with: ssh-keygen -t ed25519"
    exit 1
fi

# Check permissions
KEY_PERMS=$(stat -f "%Lp" "$SSH_KEY" 2>/dev/null || stat -c "%a" "$SSH_KEY" 2>/dev/null)
if [ "$KEY_PERMS" != "600" ]; then
    log_warn "SSH key permissions are $KEY_PERMS (should be 600). Fixing..."
    chmod 600 "$SSH_KEY"
fi

# Check SSH config
if ! grep -q "Host $SSH_HOST" "$HOME/.ssh/config" 2>/dev/null; then
    log_fail "SSH host '$SSH_HOST' not found in ~/.ssh/config"
    log_info "Add this to ~/.ssh/config:"
    log_info ""
    log_info "  Host $SSH_HOST"
    log_info "    HostName $LIGHTSAIL_IP"
    log_info "    User ubuntu"
    log_info "    IdentityFile $SSH_KEY"
    log_info "    IdentitiesOnly yes"
    exit 1
fi

log_ok "SSH key and config found"

# --- Step 3: Test SSH connectivity ---
echo ""
echo "Step 2/5: Testing SSH connectivity to $SSH_HOST..."

if ssh -o ConnectTimeout=5 -o BatchMode=yes "$SSH_HOST" "echo 'connected'" >/dev/null 2>&1; then
    log_ok "SSH connection to $SSH_HOST ($LIGHTSAIL_IP) successful"
else
    log_fail "Cannot connect to $SSH_HOST"
    log_info "Try: ssh -vvv $SSH_HOST 'echo test'"
    exit 1
fi

# --- Step 4: Retrieve DB password ---
echo ""
echo "Step 3/5: Retrieving database credentials..."

DB_PASSWORD=$(ssh "$SSH_HOST" "grep DB_POSTGRESDB_PASSWORD /home/ubuntu/n8n/.env 2>/dev/null | cut -d= -f2" 2>/dev/null || echo "")

if [ -z "$DB_PASSWORD" ]; then
    log_fail "Could not retrieve DB password from Lightsail"
    log_info "Provide it manually by creating $ENV_FILE with:"
    log_info "  GS_DB_PASSWORD=<your-password>"
    exit 1
fi

# Show only first 4 chars
MASKED="${DB_PASSWORD:0:4}$(printf '*%.0s' {1..8})"
log_ok "Database password retrieved ($MASKED)"

# --- Step 5: Set up SSH tunnel ---
echo ""
echo "Step 4/5: Setting up SSH tunnel..."

# Kill any existing tunnel on the port
if lsof -ti ":$TUNNEL_LOCAL_PORT" >/dev/null 2>&1; then
    log_warn "Killing existing process on port $TUNNEL_LOCAL_PORT"
    lsof -ti ":$TUNNEL_LOCAL_PORT" | xargs kill 2>/dev/null || true
    sleep 1
fi

# Start tunnel
ssh -f -N -L "$TUNNEL_LOCAL_PORT:$DB_DOCKER_IP:$DB_PORT" "$SSH_HOST" 2>/dev/null

if lsof -i ":$TUNNEL_LOCAL_PORT" >/dev/null 2>&1; then
    log_ok "SSH tunnel active on localhost:$TUNNEL_LOCAL_PORT -> $DB_DOCKER_IP:$DB_PORT"
else
    log_fail "Failed to start SSH tunnel"
    log_info "Try manually: ssh -f -N -L $TUNNEL_LOCAL_PORT:$DB_DOCKER_IP:$DB_PORT $SSH_HOST"
    # Continue -- tunnel is not strictly required if SSH works
fi

# --- Step 6: Write configuration files ---
echo ""
echo "Step 5/5: Writing configuration..."

GS_DB_URL="postgresql://$DB_USER:$DB_PASSWORD@localhost:$TUNNEL_LOCAL_PORT/$DB_NAME"

# Write state file
cat > "$STATE_FILE" << STATEJSON
{
  "setup_completed": true,
  "setup_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "ssh_host": "$SSH_HOST",
  "lightsail_ip": "$LIGHTSAIL_IP",
  "db_host": "$DB_DOCKER_IP",
  "db_port": $DB_PORT,
  "db_name": "$DB_NAME",
  "db_user": "$DB_USER",
  "tunnel_local_port": $TUNNEL_LOCAL_PORT,
  "current_project": null,
  "companion_plugins": {}
}
STATEJSON

# Write env file
cat > "$ENV_FILE" << ENVFILE
GS_DB_URL=$GS_DB_URL
GS_DB_PASSWORD=$DB_PASSWORD
ENVFILE

# Restrict env file permissions
chmod 600 "$ENV_FILE"

log_ok "Configuration written to $STATE_DIR/"

# --- Summary ---
echo ""
echo "==========================================="
echo "  Bootstrap Complete                       "
echo "==========================================="
echo ""
echo "  SSH:        $SSH_HOST ($LIGHTSAIL_IP)"
echo "  DB Tunnel:  localhost:$TUNNEL_LOCAL_PORT"
echo "  Database:   $DB_NAME"
echo "  State:      $STATE_FILE"
echo "  Env:        $ENV_FILE"
echo ""
echo "  Next: run /gs:status to verify everything"
echo "==========================================="
