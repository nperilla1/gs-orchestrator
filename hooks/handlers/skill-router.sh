#!/bin/bash
# UserPromptSubmit hook: Auto-detects task type and injects relevant skills
# Pattern-matches user input against keyword categories (deterministic, no LLM)
# Outputs additionalContext JSON that tells Claude which skills to use
#
# Design: Broad keyword clusters per skill category. Each cluster captures
# the many ways a user might phrase a request that maps to a skill.
# False positives are cheap (skill is suggested but ignored).
# False negatives are expensive (skill not loaded when needed).

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

# ============================================================
# ORCHESTRATION — how to approach work
# ============================================================

# Feature development / building something new
if echo "$MSG_LOWER" | grep -qE "build|create|add|implement|new feature|design|architect|develop|make|set up|setup|wire up|hook up|integrate|connect|extend|expand|introduce|support for"; then
    SKILLS="$SKILLS brainstorming feature-dev"
fi

# Debugging / fixing issues
if echo "$MSG_LOWER" | grep -qE "fix|bug|error|failing|broken|crash|exception|traceback|doesn.t work|not working|wrong|issue|problem|unexpected|weird|strange|investigate|diagnose|debug|why is|why does|why isn|what.s wrong|figure out|root cause"; then
    SKILLS="$SKILLS debugging"
fi

# TDD
if echo "$MSG_LOWER" | grep -qE "tdd|red.green|write.*test.*first|test.driven|test first"; then
    SKILLS="$SKILLS tdd"
fi

# QA / testing
if echo "$MSG_LOWER" | grep -qE "qa|sweep|test (this|the|everything|all)|run.*tests|coverage|generate tests|write tests|intent.*(discover|map)|mutation test|visual regress|heal.*test|fix.*test|test suite|pytest|jest|vitest|spec|assert"; then
    SKILLS="$SKILLS full-sweep intent-discovery"
fi

# Code review / quality check
if echo "$MSG_LOWER" | grep -qE "review|pr |pull request|code review|check my|look at my|look over|audit|inspect|examine|assess|critique|feedback on|opinion on|thoughts on|how does.*look|is this.*good|ready to merge|ready for review"; then
    SKILLS="$SKILLS code-review"
fi

# Planning / strategy
if echo "$MSG_LOWER" | grep -qE "plan|planning|strategy|approach|how should|break down|step.by.step|roadmap|outline|think through|figure out how|best way to|what.s the.*approach|architecture|high.level|overview of how"; then
    SKILLS="$SKILLS planning"
fi

# Finishing / shipping
if echo "$MSG_LOWER" | grep -qE "deploy|ship|release|merge|push|commit|done|finish|wrap up|finalize|complete|close out|ready to|all done|submit|land this"; then
    SKILLS="$SKILLS finishing-branch"
fi

# Refactoring / cleanup
if echo "$MSG_LOWER" | grep -qE "refactor|simplif|clean.?up|improve code|reorganize|restructure|tidy|consolidat|deduplic|extract|modular|decompos|split (this|into|up)|untangle|reduce complexity|too (complex|complicated|messy|long)"; then
    SKILLS="$SKILLS code-review"
fi

# ============================================================
# DOMAIN — what kind of work
# ============================================================

# Frontend / UI
if echo "$MSG_LOWER" | grep -qE "frontend|ui |ui$|ux|component|page|react|next\.?js|tailwind|css|style|layout|responsive|mobile|animation|transition|dark mode|theme|button|form|modal|nav|header|footer|sidebar|card|grid|flex|hover|font|color|spacing"; then
    SKILLS="$SKILLS aesthetics"
fi

# Marketing / advertising
if echo "$MSG_LOWER" | grep -qE "ad |ads |ad$|copy|campaign|marketing|headline|tagline|cta|ad copy|advertis|creative|conversion|click.through|ctr|impressions|audience|target.*audience|a/b test|split test|landing page copy"; then
    SKILLS="$SKILLS ad-copy campaign-strategy"
fi

# Brand / voice
if echo "$MSG_LOWER" | grep -qE "brand voice|brand guide|brand identity|style guide|writing style|tone of voice|our (voice|tone|brand)|how should.*(sound|read)|messaging guide"; then
    SKILLS="$SKILLS brand-voice"
fi

# Research / investigation
if echo "$MSG_LOWER" | grep -qE "research|investigate|explore|deep dive|find out|look into|study|analyz|understand|learn about|compare|evaluat.*options|what.*available|survey|benchmark|state of the art|best practices|how do others|alternatives"; then
    SKILLS="$SKILLS deep-research-swarm"
fi

# Website building
if echo "$MSG_LOWER" | grep -qE "website|landing page|deploy site|build site|web page|homepage|portfolio|blog site|static site|site for|new site"; then
    SKILLS="$SKILLS build-website"
fi

# Scaffolding / new projects
if echo "$MSG_LOWER" | grep -qE "scaffold|new project|bootstrap|starter|boilerplate|initializ.*project|from scratch|start fresh|greenfield|new.*(app|service|repo|package|module|codebase)$"; then
    SKILLS="$SKILLS scaffold greenfield-pipeline"
fi

# Site management
if echo "$MSG_LOWER" | grep -qE "site status|site health|deploy.*site|site analytics|check.*site|manage.*site|site.*security"; then
    SKILLS="$SKILLS site-manager"
fi

# ============================================================
# QUALITY — verification and safety
# ============================================================

# Predictive failure analysis
if echo "$MSG_LOWER" | grep -qE "predict|failure|risk|what could go wrong|production|what.*break|before.*deploy|is.*safe|could.*fail|edge case|corner case|what.*miss|blind spot|vulnerability|weak point|fragile"; then
    SKILLS="$SKILLS predict-failures"
fi

# Preflight / connectivity
if echo "$MSG_LOWER" | grep -qE "preflight|connectivity|health check|ssh|lightsail|tunnel|infrastructure|is.*running|are.*services.*up|status check|smoke test"; then
    SKILLS="$SKILLS preflight"
fi

# Evaluation / benchmarks
if echo "$MSG_LOWER" | grep -qE "eval|evaluat.*qual|benchmark|pass@k|metric|score|measure|how.*good|how.*well|quality of|accuracy|reliability|consistency"; then
    SKILLS="$SKILLS eval-harness"
fi

# Completeness check
if echo "$MSG_LOWER" | grep -qE "complete|thorough|comprehensive|anything.*miss|forget|check.*everything|audit|coverage|gap|missing|all.*cases|full.*check|nothing.*left"; then
    SKILLS="$SKILLS completeness-audit"
fi

# ============================================================
# PROMPT ENGINEERING — writing for LLMs
# ============================================================

# Prompt writing
if echo "$MSG_LOWER" | grep -qE "prompt|system message|instructions|write a prompt|system prompt|prompt template|prompt engineer|few.shot|chain.of.thought|prompt design"; then
    SKILLS="$SKILLS writing-prompts"
fi

# CLAUDE.md maintenance
if echo "$MSG_LOWER" | grep -qE "claude\.?md|project instructions|project memory|update.*claude|project.*context|project.*rules"; then
    SKILLS="$SKILLS writing-claude-md"
fi

# Skill / agent creation
if echo "$MSG_LOWER" | grep -qE "write.*(skill|agent)|create.*(skill|agent)|new.*(skill|agent)|skill.*file|agent.*definition|skill.*template|agent.*template"; then
    SKILLS="$SKILLS writing-skills writing-agents"
fi

# Context engineering
if echo "$MSG_LOWER" | grep -qE "context.*engineer|context.*window|context.*manag|token.*budget|context.*rot|compress.*context|reduce.*context|too.*long|too.*large|context.*limit"; then
    SKILLS="$SKILLS context-engineering"
fi

# ============================================================
# GIT — version control operations
# ============================================================

# Commits
if echo "$MSG_LOWER" | grep -qE "commit|git commit|save.*changes|stage.*changes|check.*in"; then
    SKILLS="$SKILLS commit"
fi

# Worktrees / parallel work
if echo "$MSG_LOWER" | grep -qE "worktree|parallel branch|isolat|work.*parallel|side.*branch|separate.*branch"; then
    SKILLS="$SKILLS worktrees"
fi

# Branch cleanup
if echo "$MSG_LOWER" | grep -qE "clean.*branch|prune|stale branch|gone branch|delete.*branch|remove.*branch|old branch"; then
    SKILLS="$SKILLS clean-gone"
fi

# ============================================================
# DATABASE — data operations
# ============================================================

if echo "$MSG_LOWER" | grep -qE "database|sql|query|schema|table|migration|postgres|alembic|model.*field|column|index|foreign key|constraint|db "; then
    # Suggest db-analyst agent but no skill injection needed
    :
fi

# ============================================================
# LEARNING — continuous improvement
# ============================================================

if echo "$MSG_LOWER" | grep -qE "learn|pattern|instinct|observation|crystalliz|what.*learned|session.*notes|takeaway|insight|lesson"; then
    SKILLS="$SKILLS continuous-learning"
fi

# ============================================================
# Deduplicate and output
# ============================================================

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
