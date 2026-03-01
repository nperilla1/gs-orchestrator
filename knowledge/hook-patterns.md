# Hook Patterns -- Claude Code Hook Events Reference

Complete reference for all Claude Code hook events, their triggers, inputs, outputs, and practical examples.

## Hook Architecture

Hooks are shell scripts that run at specific lifecycle events. They receive JSON on stdin and can influence Claude's behavior through stdout JSON and exit codes.

### Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success -- proceed normally |
| 1 | Warning -- proceed but show the warning |
| 2 | Block -- prevent the action and show the error message |

### Output Format

Hooks can output JSON to stdout to inject context:

```json
{
  "additionalContext": "Text that will be injected into Claude's context"
}
```

For PreToolUse hooks, you can also modify the tool input:

```json
{
  "tool_input": { "modified": "input" }
}
```

## Hook Events

### 1. SessionStart

**When**: At the beginning of every Claude Code session.

**Stdin**: Empty or minimal session metadata.

**Use cases**:
- First-run detection and setup prompts
- Environment health checks (SSH, DB tunnels)
- Context injection (current project, recent state)
- Loading persistent state from disk

**Example** (bootstrap.sh):
```bash
#!/bin/bash
if [ ! -f "$HOME/.gs-orchestrator/state.json" ]; then
    echo '{"additionalContext": "First run detected. Run /gs:setup to configure."}'
fi
exit 0
```

### 2. SessionEnd

**When**: When the Claude Code session is ending.

**Stdin**: Session metadata.

**Use cases**:
- Saving session state
- Cleaning up temporary files
- Recording session metrics
- Auto-triggering /gs:learn for instinct extraction

**Example**:
```bash
#!/bin/bash
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) session_end" >> ~/.gs-orchestrator/session-log.jsonl
exit 0
```

### 3. UserPromptSubmit

**When**: After the user submits a prompt, before Claude processes it.

**Stdin**:
```json
{
  "message": "The user's message text",
  "content": "Alternative field for message content"
}
```

**Use cases**:
- Skill routing (pattern-match user intent to inject relevant skills)
- Input validation or transformation
- Context injection based on user intent
- Logging user prompts for analysis

**Example** (skill-router.sh):
```bash
#!/bin/bash
INPUT=$(cat)
MSG=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('message',''))" 2>/dev/null)
MSG_LOWER=$(echo "$MSG" | tr '[:upper:]' '[:lower:]')

if echo "$MSG_LOWER" | grep -qE "fix|bug|error"; then
    echo '{"additionalContext": "Relevant skills: debugging"}'
fi
exit 0
```

### 4. PreToolUse

**When**: Before a tool is invoked. Allows blocking or modifying tool calls.

**Matcher**: Can filter by tool name regex (e.g., `"Edit|Write"`, `"Bash"`).

**Stdin**:
```json
{
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "/path/to/file.py",
    "old_string": "...",
    "new_string": "..."
  }
}
```

**Use cases**:
- File protection (block edits to test files, secrets)
- Command validation (block destructive bash commands)
- Input sanitization
- Audit logging of all tool usage

**Example** (block test edits):
```bash
#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | python3 -c "
import sys,json
d=json.load(sys.stdin)
print(d.get('tool_input',{}).get('file_path',''))
" 2>/dev/null)

if echo "$FILE" | grep -qE "tests?/|_test\.py$|test_.*\.py$"; then
    echo "BLOCKED: Test files are read-only." >&2
    exit 2
fi
exit 0
```

### 5. PostToolUse

**When**: After a tool completes successfully.

**Matcher**: Can filter by tool name regex.

**Stdin**:
```json
{
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "/path/to/file.py"
  },
  "tool_output": "..."
}
```

**Use cases**:
- Syntax validation after file writes
- Auto-formatting (ruff, biome)
- Audit logging
- Triggering dependent actions (e.g., restart dev server after config change)

**Example** (Python syntax check):
```bash
#!/bin/bash
INPUT=$(cat)
FILE=$(echo "$INPUT" | python3 -c "
import sys,json
d=json.load(sys.stdin)
print(d.get('tool_input',{}).get('file_path',''))
" 2>/dev/null)

if echo "$FILE" | grep -qE '\.py$' && [ -f "$FILE" ]; then
    python3 -m py_compile "$FILE" 2>&1
    if [ $? -ne 0 ]; then
        echo "Syntax error in $FILE" >&2
        exit 1
    fi
fi
exit 0
```

**Async option**: Set `"async": true` in hooks.json for non-blocking post-processing (e.g., formatting).

### 6. Stop

**When**: Before Claude stops responding (about to hand control back to user).

**Stdin**: Minimal metadata.

**Use cases**:
- Completion gates (block stopping if tests fail)
- Final validation checks
- Auto-commit prompts
- Session summary generation

**Example** (completion gate):
```bash
#!/bin/bash
if [ -f ".gs-completion-gate" ]; then
    RESULT=$(python3 -m pytest tests/ -q --tb=no 2>&1)
    if [ $? -ne 0 ]; then
        echo "Tests failing. Fix before stopping." >&2
        echo "$RESULT" | tail -10 >&2
        exit 2
    fi
fi
exit 0
```

### 7. SubagentStop

**When**: Before a subagent completes its task.

**Use cases**:
- Validating subagent output quality
- Injecting additional instructions for the subagent
- Logging subagent activity

### 8. PreCompact

**When**: Before context compaction occurs (conversation is getting too long).

**Use cases**:
- Saving critical state to disk
- Writing a recovery checkpoint
- Injecting a "remember this after compaction" note

**Example** (save state):
```bash
#!/bin/bash
{
    echo "# Pre-Compact State"
    echo "Branch: $(git branch --show-current 2>/dev/null)"
    echo "Modified: $(git diff --name-only 2>/dev/null | wc -l) files"
} > ~/.gs-orchestrator/pre-compact-state.md

echo '{"additionalContext": "State saved. Read ~/.gs-orchestrator/pre-compact-state.md after compaction."}'
exit 0
```

### 9. Notification

**When**: When a notification should be shown to the user.

**Use cases**:
- Custom notification formatting
- Routing notifications to external systems
- Filtering noise

## hooks.json Structure

```json
{
  "EventName": [
    {
      "matcher": "ToolNameRegex",
      "hooks": [
        {
          "type": "command",
          "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/handlers/script.sh",
          "timeout": 10,
          "async": false
        }
      ]
    }
  ]
}
```

**Fields**:
- `matcher`: Only for PreToolUse/PostToolUse -- regex matching tool names
- `type`: Always `"command"` for shell scripts
- `command`: The command to run. `${CLAUDE_PLUGIN_ROOT}` resolves to the plugin directory.
- `timeout`: Maximum seconds before the hook is killed (default varies by event)
- `async`: If true, the hook runs in the background and does not block

## Best Practices

- Keep hooks fast (under 5 seconds for blocking hooks)
- Use `exit 0` for informational output, `exit 2` to block
- Parse stdin with Python for reliability (jq can also work)
- Always handle empty/malformed stdin gracefully
- Use `>&2` for error messages that should appear to the user
- Use stdout JSON for context injection
- Test hooks independently before deploying: `echo '{"tool_name":"Edit","tool_input":{"file_path":"test.py"}}' | bash hook.sh`
