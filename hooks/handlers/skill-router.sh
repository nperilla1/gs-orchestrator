#!/bin/bash
# UserPromptSubmit hook: Auto-detects task type and injects relevant skills
# Pattern-matches user input against keyword categories (deterministic, no LLM)
# Outputs additionalContext JSON that tells Claude which skills to use

INPUT=$(cat)

# Extract the user's message text
MESSAGE=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('message', data.get('content', '')))
except:
    print('')
" 2>/dev/null)

# Lowercase for matching
MSG_LOWER=$(echo "$MESSAGE" | tr '[:upper:]' '[:lower:]')

if [ -z "$MSG_LOWER" ]; then
    exit 0
fi

SKILLS=""

# Orchestration patterns
if echo "$MSG_LOWER" | grep -qE "build|create|add|implement|new feature|design|architect"; then
    SKILLS="$SKILLS brainstorming feature-dev"
fi

if echo "$MSG_LOWER" | grep -qE "fix|bug|error|failing|broken|crash|exception|traceback"; then
    SKILLS="$SKILLS debugging"
fi

if echo "$MSG_LOWER" | grep -qE "tdd|red.green|write.*test.*first"; then
    SKILLS="$SKILLS tdd"
fi

# QA patterns — full sweep, intent discovery, test generation
if echo "$MSG_LOWER" | grep -qE "qa|sweep|test (this|the|everything|all)|run.*tests|coverage|generate tests|write tests|intent.*(discover|map)|mutation test|visual regress|heal.*test|fix.*test"; then
    SKILLS="$SKILLS full-sweep intent-discovery"
fi

if echo "$MSG_LOWER" | grep -qE "review|pr |pull request|code review|check my"; then
    SKILLS="$SKILLS code-review"
fi

if echo "$MSG_LOWER" | grep -qE "plan|planning|strategy|approach|how should|break down"; then
    SKILLS="$SKILLS planning"
fi

if echo "$MSG_LOWER" | grep -qE "deploy|ship|release|merge|push|commit"; then
    SKILLS="$SKILLS finishing-branch"
fi

if echo "$MSG_LOWER" | grep -qE "refactor|simplif|clean.?up|improve code|reorganize"; then
    SKILLS="$SKILLS code-review"
fi

# Domain patterns
if echo "$MSG_LOWER" | grep -qE "frontend|ui |component|page|react|next\.?js|tailwind|css"; then
    SKILLS="$SKILLS aesthetics"
fi

if echo "$MSG_LOWER" | grep -qE "ad |copy|campaign|marketing|headline|tagline|cta|ad copy"; then
    SKILLS="$SKILLS ad-copy campaign-strategy"
fi

if echo "$MSG_LOWER" | grep -qE "brand|voice|tone|messaging|brand guide"; then
    SKILLS="$SKILLS brand-voice"
fi

if echo "$MSG_LOWER" | grep -qE "research|investigate|explore|deep dive|find out|look into"; then
    SKILLS="$SKILLS deep-research-swarm"
fi

if echo "$MSG_LOWER" | grep -qE "website|landing page|deploy site|build site"; then
    SKILLS="$SKILLS build-website"
fi

if echo "$MSG_LOWER" | grep -qE "scaffold|new project|bootstrap|starter|boilerplate"; then
    SKILLS="$SKILLS scaffold greenfield-pipeline"
fi

# Quality patterns
if echo "$MSG_LOWER" | grep -qE "predict|failure|risk|what could go wrong|production"; then
    SKILLS="$SKILLS predict-failures"
fi

if echo "$MSG_LOWER" | grep -qE "preflight|connectivity|health check|ssh|lightsail"; then
    SKILLS="$SKILLS preflight"
fi

if echo "$MSG_LOWER" | grep -qE "eval|evaluat|benchmark|pass@k|metric"; then
    SKILLS="$SKILLS eval-harness"
fi

# Prompt engineering patterns
if echo "$MSG_LOWER" | grep -qE "prompt|system message|instructions|write a prompt"; then
    SKILLS="$SKILLS writing-prompts"
fi

if echo "$MSG_LOWER" | grep -qE "claude\.?md|project instructions|project memory"; then
    SKILLS="$SKILLS writing-claude-md"
fi

if echo "$MSG_LOWER" | grep -qE "write.*(skill|agent)|create.*(skill|agent)|new.*(skill|agent)"; then
    SKILLS="$SKILLS writing-skills writing-agents"
fi

# Git patterns
if echo "$MSG_LOWER" | grep -qE "commit|git commit"; then
    SKILLS="$SKILLS commit"
fi

if echo "$MSG_LOWER" | grep -qE "worktree|parallel branch|isolat"; then
    SKILLS="$SKILLS worktrees"
fi

# Database patterns
if echo "$MSG_LOWER" | grep -qE "database|sql|query|schema|table|migration|postgres"; then
    # No skill injection, but the db-analyst agent will be available
    :
fi

# Deduplicate skills
if [ -n "$SKILLS" ]; then
    UNIQUE_SKILLS=$(echo "$SKILLS" | tr ' ' '\n' | sort -u | tr '\n' ' ' | sed 's/ $//')

    # Build the context message
    SKILL_MSG="Relevant skills detected for this task: $UNIQUE_SKILLS. Consider using these skills (invoke via the Skill tool if applicable) to guide your approach."

    cat <<CONTEXT
{
  "additionalContext": "$SKILL_MSG"
}
CONTEXT
fi

exit 0
