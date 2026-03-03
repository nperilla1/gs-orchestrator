#!/bin/bash
# ============================================================
# Authorize a team member's SSH key on Lightsail
# ============================================================
#
# Usage:
#   bash authorize-key.sh "ssh-ed25519 AAAAC3Nza... gs-jane-doe"
#
# Or paste interactively:
#   bash authorize-key.sh
#
# ============================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

if [ -n "$1" ]; then
    PUBKEY="$*"
else
    echo "Paste the public key the team member sent you, then press Enter:"
    echo ""
    read -r PUBKEY
fi

if [ -z "$PUBKEY" ]; then
    echo -e "${RED}✗${NC} No key provided"
    exit 1
fi

# Validate it looks like a public key
if ! echo "$PUBKEY" | grep -qE "^ssh-(ed25519|rsa) "; then
    echo -e "${RED}✗${NC} That doesn't look like a public key."
    echo "  It should start with 'ssh-ed25519' or 'ssh-rsa'"
    exit 1
fi

# Extract the label for display
LABEL=$(echo "$PUBKEY" | awk '{print $3}')
echo ""
echo "Adding key: ${LABEL:-unnamed}"

# Add to authorized_keys on Lightsail (idempotent — won't duplicate)
ssh gs-production-v2 "grep -qF '${PUBKEY}' ~/.ssh/authorized_keys 2>/dev/null && echo 'ALREADY_EXISTS' || echo '${PUBKEY}' >> ~/.ssh/authorized_keys"

RESULT=$?
if [ $RESULT -eq 0 ]; then
    # Check if it was already there
    LAST_OUTPUT=$(ssh gs-production-v2 "grep -cF '${PUBKEY}' ~/.ssh/authorized_keys")
    echo -e "${GREEN}✓${NC} Key authorized for ${LABEL:-team member}"
    echo ""
    echo "  Tell them to run the setup script again to finish."
else
    echo -e "${RED}✗${NC} Failed to add key. Check your SSH connection."
    exit 1
fi
