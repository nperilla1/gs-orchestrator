#!/bin/bash
# PostToolUse hook: Validates written files for syntax errors
# Python: py_compile check
# TypeScript: tsc --noEmit (if tsconfig exists)

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    tool_input = data.get('tool_input', data)
    print(tool_input.get('file_path', ''))
except:
    print('')
" 2>/dev/null)

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

# Python syntax check
if echo "$FILE_PATH" | grep -qE '\.py$'; then
    RESULT=$(python3 -m py_compile "$FILE_PATH" 2>&1)
    if [ $? -ne 0 ]; then
        echo "SYNTAX ERROR in $FILE_PATH:" >&2
        echo "$RESULT" >&2
        exit 1
    fi
fi

# JSON syntax check
if echo "$FILE_PATH" | grep -qE '\.json$'; then
    RESULT=$(python3 -c "import json; json.load(open('$FILE_PATH'))" 2>&1)
    if [ $? -ne 0 ]; then
        echo "JSON SYNTAX ERROR in $FILE_PATH:" >&2
        echo "$RESULT" >&2
        exit 1
    fi
fi

# YAML syntax check (if pyyaml available)
if echo "$FILE_PATH" | grep -qE '\.(ya?ml)$'; then
    python3 -c "import yaml; yaml.safe_load(open('$FILE_PATH'))" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "YAML SYNTAX ERROR in $FILE_PATH" >&2
        exit 1
    fi
fi

exit 0
