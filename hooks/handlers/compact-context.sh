#!/bin/bash
# PreCompact hook: Saves critical state before context compaction
# Writes current task state, modified files, and key decisions to a recovery file

STATE_DIR="$HOME/.gs-orchestrator"
COMPACT_FILE="$STATE_DIR/pre-compact-state.md"

mkdir -p "$STATE_DIR"

# Capture current state
{
    echo "# Pre-Compact State Save"
    echo "Saved at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo ""

    # Current working directory
    echo "## Working Directory"
    echo "\`$PWD\`"
    echo ""

    # Git state if in a repo
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "## Git State"
        echo "Branch: $(git branch --show-current 2>/dev/null)"
        echo "Last commit: $(git log --oneline -1 2>/dev/null)"
        echo ""

        # Modified files
        MODIFIED=$(git diff --name-only 2>/dev/null)
        if [ -n "$MODIFIED" ]; then
            echo "## Modified Files (unstaged)"
            echo "$MODIFIED" | while read -r f; do echo "- $f"; done
            echo ""
        fi

        STAGED=$(git diff --cached --name-only 2>/dev/null)
        if [ -n "$STAGED" ]; then
            echo "## Staged Files"
            echo "$STAGED" | while read -r f; do echo "- $f"; done
            echo ""
        fi
    fi

    # Active SSH tunnels
    TUNNELS=$(lsof -i -P 2>/dev/null | grep ssh | grep LISTEN | awk '{print $9}')
    if [ -n "$TUNNELS" ]; then
        echo "## Active SSH Tunnels"
        echo "$TUNNELS" | while read -r t; do echo "- $t"; done
        echo ""
    fi

} > "$COMPACT_FILE"

# Inject as additional context so Claude remembers after compaction
cat <<CONTEXT
{
  "additionalContext": "Context compaction occurring. Critical state saved to $COMPACT_FILE. After compaction, read this file to restore context about current work, modified files, and active infrastructure."
}
CONTEXT

exit 0
