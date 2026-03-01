#!/bin/bash
# PostToolUse hook (async): Auto-formats files after Edit/Write
# Python: ruff format + ruff check --fix
# TypeScript/JavaScript: biome format (if available)

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

# Python files: ruff
if echo "$FILE_PATH" | grep -qE '\.py$'; then
    if command -v ruff &>/dev/null; then
        ruff format "$FILE_PATH" 2>/dev/null
        ruff check --fix --silent "$FILE_PATH" 2>/dev/null
    fi
fi

# TypeScript/JavaScript files: biome
if echo "$FILE_PATH" | grep -qE '\.(ts|tsx|js|jsx)$'; then
    if command -v biome &>/dev/null; then
        biome format --write "$FILE_PATH" 2>/dev/null
    elif command -v npx &>/dev/null; then
        # Try project-local biome
        npx --no biome format --write "$FILE_PATH" 2>/dev/null
    fi
fi

exit 0
