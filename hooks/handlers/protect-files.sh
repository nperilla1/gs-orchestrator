#!/bin/bash
# PreToolUse hook: Blocks dangerous operations
# Merges tdd-guard (blocks test file edits) + destructive-guard (blocks dangerous commands)
# Exit code 2 = blocking error

INPUT=$(cat)

# Extract tool name and input
TOOL_NAME=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('tool_name', ''))
except:
    print('')
" 2>/dev/null)

TOOL_INPUT=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    ti = data.get('tool_input', {})
    print(json.dumps(ti))
except:
    print('{}')
" 2>/dev/null)

# === TDD Guard: Block test file modifications ===
if [ "$TOOL_NAME" = "Edit" ] || [ "$TOOL_NAME" = "Write" ]; then
    FILE_PATH=$(echo "$TOOL_INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('file_path', ''))
except:
    print('')
" 2>/dev/null)

    if [ -n "$FILE_PATH" ]; then
        if echo "$FILE_PATH" | grep -qE "(^|/)tests?/|_test\.py$|test_[^/]*\.py$|\.test\.(ts|js|tsx|jsx)$|__tests__/|/spec/|\.spec\.(ts|js|tsx|jsx)$|conftest\.py$|/fixtures/"; then
            echo "BLOCKED: Test files are read-only during implementation." >&2
            echo "Fix the implementation code to make the tests pass, do NOT modify the tests." >&2
            echo "File: $FILE_PATH" >&2
            exit 2
        fi

        # Block writing to secret files
        if echo "$FILE_PATH" | grep -qiE "\.env$|\.env\.|credentials|secrets|\.pem$|\.key$|id_rsa|id_ed25519"; then
            echo "BLOCKED: Cannot write to secret/credential files." >&2
            echo "File: $FILE_PATH" >&2
            exit 2
        fi
    fi
fi

# === Destructive Command Guard ===
if [ "$TOOL_NAME" = "Bash" ]; then
    COMMAND=$(echo "$TOOL_INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('command', ''))
except:
    print('')
" 2>/dev/null)

    if [ -z "$COMMAND" ]; then
        exit 0
    fi

    BLOCKED=""

    # File system destruction
    if echo "$COMMAND" | grep -qE "rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|--recursive\s+--force|-[a-zA-Z]*f[a-zA-Z]*r)\s"; then
        BLOCKED="rm -rf detected"
    fi

    # Database destruction
    if echo "$COMMAND" | grep -qiE "DROP\s+(TABLE|DATABASE|SCHEMA|INDEX)"; then
        BLOCKED="DROP statement detected"
    fi
    if echo "$COMMAND" | grep -qiE "TRUNCATE\s+"; then
        BLOCKED="TRUNCATE detected"
    fi
    if echo "$COMMAND" | grep -qiE "DELETE\s+FROM\s+\w+\s*;?\s*$"; then
        BLOCKED="DELETE without WHERE clause detected"
    fi

    # Git destruction
    if echo "$COMMAND" | grep -qE "git\s+push\s+.*--force|git\s+push\s+-f\s"; then
        BLOCKED="git push --force detected"
    fi
    if echo "$COMMAND" | grep -qE "git\s+reset\s+--hard"; then
        BLOCKED="git reset --hard detected"
    fi
    if echo "$COMMAND" | grep -qE "git\s+clean\s+-[a-zA-Z]*f"; then
        BLOCKED="git clean -f detected"
    fi
    if echo "$COMMAND" | grep -qE "git\s+branch\s+-D\s"; then
        BLOCKED="git branch -D detected"
    fi

    # System destruction
    if echo "$COMMAND" | grep -qE "mkfs\.|dd\s+if=|chmod\s+-R\s+777|chown\s+-R\s+"; then
        BLOCKED="Dangerous system command detected"
    fi

    # Docker destruction
    if echo "$COMMAND" | grep -qE "docker\s+(system\s+prune|volume\s+prune|container\s+prune)\s+-f|docker\s+rm\s+-f\s+\\\$\(docker\s+ps"; then
        BLOCKED="Docker mass cleanup detected"
    fi

    if [ -n "$BLOCKED" ]; then
        echo "BLOCKED: $BLOCKED" >&2
        echo "This command could cause irreversible damage. Ask the user for explicit confirmation." >&2
        echo "Command: $COMMAND" >&2
        exit 2
    fi
fi

exit 0
