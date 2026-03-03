#!/bin/bash
# ============================================================
# GS Orchestrator — One-Command Team Setup
# ============================================================
#
# BEFORE RUNNING:
#   1. Install Claude Code:  npm install -g @anthropic-ai/claude-code
#
# THEN RUN:
#   bash team-setup.sh
#
# The script generates a personal SSH key and tells you what
# to send to Nicolas. Once he authorizes your key, run it again
# to finish setup.
#
# ============================================================

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; }
info() { echo -e "  ${BLUE}→${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }

echo ""
echo "============================================"
echo "  GS Orchestrator — Team Setup"
echo "============================================"
echo ""

# ----------------------------------------------------------
# Step 1: Check for Claude Code
# ----------------------------------------------------------
echo "Step 1/6: Checking for Claude Code..."

if command -v claude &>/dev/null; then
    ok "Claude Code is installed"
else
    fail "Claude Code is not installed"
    echo ""
    echo "  Install it first:"
    echo "    npm install -g @anthropic-ai/claude-code"
    echo ""
    echo "  If you don't have npm, install Node.js first:"
    echo "    https://nodejs.org/en/download"
    echo ""
    exit 1
fi

# ----------------------------------------------------------
# Step 2: Generate personal SSH key
# ----------------------------------------------------------
echo "Step 2/6: Setting up SSH key..."

mkdir -p ~/.ssh
chmod 700 ~/.ssh

GS_KEY="$HOME/.ssh/gs-production-v2"

if [ -f "$GS_KEY" ]; then
    ok "SSH key already exists at $GS_KEY"
else
    # Get their name for the key comment
    WHOAMI=$(whoami)
    read -p "  Enter your name (for the key label): " KEY_NAME
    KEY_NAME="${KEY_NAME:-$WHOAMI}"

    ssh-keygen -t ed25519 -f "$GS_KEY" -N "" -C "gs-${KEY_NAME// /-}" >/dev/null 2>&1
    ok "Generated SSH key at $GS_KEY"
fi

chmod 600 "$GS_KEY"

# ----------------------------------------------------------
# Step 3: Configure SSH
# ----------------------------------------------------------
echo "Step 3/6: Configuring SSH..."

if grep -q "gs-production-v2" ~/.ssh/config 2>/dev/null; then
    ok "SSH config already has gs-production-v2 entry"
else
    cat >> ~/.ssh/config << SSHEOF

Host gs-production-v2
  HostName 52.72.246.186
  User ubuntu
  IdentityFile ${GS_KEY}
  IdentitiesOnly yes
SSHEOF
    chmod 600 ~/.ssh/config
    ok "Added gs-production-v2 to SSH config"
fi

# ----------------------------------------------------------
# Step 4: Test SSH
# ----------------------------------------------------------
echo "Step 4/6: Testing SSH connection..."

if ssh -o ConnectTimeout=10 -o BatchMode=yes -o StrictHostKeyChecking=accept-new gs-production-v2 "echo ok" &>/dev/null; then
    ok "SSH connection to Lightsail works"
else
    echo ""
    warn "SSH connection not authorized yet."
    echo ""
    echo "  ┌─────────────────────────────────────────────────┐"
    echo "  │  Send this to Nicolas:                          │"
    echo "  └─────────────────────────────────────────────────┘"
    echo ""
    echo "  $(cat "${GS_KEY}.pub")"
    echo ""
    echo "  ┌─────────────────────────────────────────────────┐"
    echo "  │  Copy the line above and send it to Nicolas     │"
    echo "  │  via Slack or text. He'll authorize it.         │"
    echo "  │                                                 │"
    echo "  │  Then run this script again to finish setup.    │"
    echo "  └─────────────────────────────────────────────────┘"
    echo ""
    exit 0
fi

# ----------------------------------------------------------
# Step 5: Install plugins
# ----------------------------------------------------------
echo "Step 5/6: Installing Claude Code plugins..."

install_plugin() {
    local name="$1"
    local source="$2"
    if claude plugin list 2>/dev/null | grep -qi "$name"; then
        ok "$name already installed"
    else
        if claude plugin add "${name}@${source}" 2>/dev/null; then
            ok "$name installed"
        else
            warn "$name failed to install (non-critical, continue)"
        fi
    fi
}

install_plugin "gs-orchestrator" "gs-marketplace"
install_plugin "superpowers" "claude-plugins-official"
install_plugin "coderabbit" "claude-plugins-official"

# ----------------------------------------------------------
# Step 6: Initialize orchestrator config
# ----------------------------------------------------------
echo "Step 6/6: Configuring orchestrator..."

mkdir -p ~/.gs-orchestrator

# Get DB password
DB_PASS=$(ssh gs-production-v2 "grep DB_POSTGRESDB_PASSWORD /home/ubuntu/n8n/.env | cut -d= -f2" 2>/dev/null)

if [ -z "$DB_PASS" ]; then
    fail "Could not retrieve database password"
    echo "  SSH works but couldn't read the env file."
    echo "  Ask Nicolas for help."
    exit 1
fi

# Write state
cat > ~/.gs-orchestrator/state.json << JSONEOF
{
  "setup_completed": true,
  "setup_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "ssh_host": "gs-production-v2",
  "db_host": "172.18.0.12",
  "db_port": 5432,
  "db_name": "gs_unified",
  "db_user": "n8n",
  "tunnel_local_port": 5434,
  "current_project": null,
  "companion_plugins": {
    "superpowers": true,
    "coderabbit": true
  }
}
JSONEOF

# Write .env
cat > ~/.gs-orchestrator/.env << ENVEOF
GS_DB_URL=postgresql://n8n:${DB_PASS}@localhost:5434/gs_unified
GS_DB_PASSWORD=${DB_PASS}
ENVEOF
chmod 600 ~/.gs-orchestrator/.env

ok "Configuration saved"

# Start tunnel
lsof -ti :5434 2>/dev/null | xargs kill 2>/dev/null
sleep 1
ssh -f -N -L 5434:172.18.0.12:5432 gs-production-v2 2>/dev/null

if lsof -i :5434 2>/dev/null | grep -q LISTEN; then
    ok "Database tunnel started (localhost:5434)"
else
    warn "Tunnel didn't start — will auto-start next Claude Code session"
fi

# ----------------------------------------------------------
# Done
# ----------------------------------------------------------
echo ""
echo "============================================"
echo -e "  ${GREEN}Setup Complete!${NC}"
echo "============================================"
echo ""
echo "  To start working:"
echo ""
echo "    cd /path/to/gs-production-v2"
echo "    claude"
echo ""
echo "  Useful commands inside Claude Code:"
echo ""
echo "    /gs:status      Check everything is connected"
echo "    /gs:start       Start a task autonomously"
echo ""
echo "  The database tunnel will auto-restart"
echo "  each time you open Claude Code."
echo ""
echo "============================================"
echo ""
