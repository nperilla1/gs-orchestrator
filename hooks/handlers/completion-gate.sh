#!/bin/bash
# Stop hook: Blocks Claude from stopping until tests pass (opt-in)
# Only active when .gs-completion-gate file exists in the project root
# Exit code 2 = block the stop

# Find the project root (look for common markers)
find_project_root() {
    local dir="$PWD"
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/.gs-completion-gate" ]; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

PROJECT_ROOT=$(find_project_root)

# No gate file = don't block
if [ -z "$PROJECT_ROOT" ]; then
    exit 0
fi

# Read gate configuration
GATE_CONFIG=$(cat "$PROJECT_ROOT/.gs-completion-gate" 2>/dev/null)

# Default test command based on project type
TEST_CMD=""
if [ -f "$PROJECT_ROOT/pyproject.toml" ] || [ -f "$PROJECT_ROOT/setup.py" ]; then
    TEST_CMD="python3 -m pytest tests/ -q --tb=no 2>&1"
elif [ -f "$PROJECT_ROOT/package.json" ]; then
    TEST_CMD="npm test 2>&1"
fi

# Override with gate config if provided
if [ -n "$GATE_CONFIG" ]; then
    TEST_CMD="$GATE_CONFIG"
fi

if [ -z "$TEST_CMD" ]; then
    exit 0
fi

# Run tests
cd "$PROJECT_ROOT"
RESULT=$(eval "$TEST_CMD" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "COMPLETION GATE: Tests are failing. Fix the failures before stopping." >&2
    echo "" >&2
    # Show last 20 lines of test output
    echo "$RESULT" | tail -20 >&2
    exit 2
fi

exit 0
