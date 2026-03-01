---
name: continuous-learning
description: The instinct system for continuous learning across Claude Code sessions. Three phases -- OBSERVE (structured logging of tool use patterns, decisions, and outcomes), CRYSTALLIZE (detect recurring patterns and form instincts with confidence scores 0.3-0.9), and EVOLVE (promote high-confidence instincts to full skills). Instincts are lightweight pattern-action pairs stored in ~/.gs-orchestrator/instincts.jsonl. Unlike skills which are explicit instructions, instincts are emergent patterns discovered from actual usage. Team members share instincts via export/import. Use /gs:observe to log, /gs:crystallize to form instincts, /gs:evolve to promote instincts to skills.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Continuous Learning -- The Instinct System

You are operating the instinct system, which enables Claude Code to learn from experience across sessions. Instincts are lightweight pattern-action pairs that emerge from actual usage, unlike skills which are explicitly authored.

## Target
$ARGUMENTS
(One of: observe, crystallize, evolve, list, export, import)

## Core Concepts

### What is an Instinct?

An instinct is a pattern-action pair with a confidence score:

```json
{
  "id": "inst_2026_03_01_001",
  "pattern": "When writing SQLAlchemy async queries with JSONB columns",
  "action": "Always json.dumps() before passing to asyncpg, then CAST to jsonb",
  "confidence": 0.8,
  "observations": 5,
  "last_seen": "2026-03-01T14:30:00Z",
  "source": "writer-project",
  "tags": ["sqlalchemy", "asyncpg", "jsonb", "gotcha"]
}
```

### Instinct vs Skill vs Rule

| | Instinct | Skill | Rule |
|---|---|---|---|
| **Origin** | Emerged from usage | Authored explicitly | Authored explicitly |
| **Confidence** | 0.3-0.9 (earned) | 1.0 (assumed) | 1.0 (assumed) |
| **Size** | 1-3 sentences | Full document | 1-5 sentences |
| **Scope** | Narrow pattern | Complete workflow | Constraint/policy |
| **Location** | instincts.jsonl | SKILL.md | CLAUDE.md rules |
| **Lifecycle** | Observe -> Crystallize -> Evolve | Write -> Use -> Refine | Write -> Enforce |

## Phase 1: OBSERVE -- Structured Logging

Log observations about decisions, outcomes, and patterns.

### What to Log

```json
{
  "timestamp": "2026-03-01T14:30:00Z",
  "session_id": "session_abc123",
  "category": "decision | outcome | pattern | gotcha | success",
  "context": "What was happening when this occurred",
  "observation": "What specifically happened or was decided",
  "outcome": "positive | negative | neutral",
  "tags": ["relevant", "keywords"]
}
```

### Categories

- **decision**: A choice was made between alternatives. Log what was chosen and why.
- **outcome**: The result of an action. Log whether it succeeded, failed, or had unexpected effects.
- **pattern**: A recurring situation noticed across sessions. Log the pattern and what works.
- **gotcha**: Something that caused wasted time. Log the trap and the escape.
- **success**: Something that worked especially well. Log the approach.

### Logging Command

Append to the instinct observation log:

```bash
mkdir -p ~/.gs-orchestrator
cat >> ~/.gs-orchestrator/observations.jsonl << 'EOF'
{"timestamp":"2026-03-01T14:30:00Z","category":"gotcha","context":"Writing async SQLAlchemy query with dict parameter","observation":"asyncpg cannot serialize Python dict to jsonb - must json.dumps() first","outcome":"negative","tags":["asyncpg","jsonb","sqlalchemy"]}
EOF
```

## Phase 2: CRYSTALLIZE -- Form Instincts

Analyze accumulated observations and detect recurring patterns.

### Process

1. Read all observations:
   ```bash
   cat ~/.gs-orchestrator/observations.jsonl
   ```

2. Group by tags and categories

3. For each group with 3+ observations:
   - Identify the recurring pattern
   - Formulate the action (what to do when the pattern is detected)
   - Assign initial confidence based on observation count:
     - 3 observations: 0.3 (weak instinct)
     - 5 observations: 0.5 (moderate instinct)
     - 8+ observations: 0.7 (strong instinct)
     - 12+ observations with consistent outcomes: 0.9 (very strong)

4. Write instinct to the instinct file:
   ```bash
   cat >> ~/.gs-orchestrator/instincts.jsonl << 'EOF'
   {"id":"inst_2026_03_01_001","pattern":"When writing SQLAlchemy async queries with JSONB columns","action":"Always json.dumps() before passing to asyncpg, then CAST to jsonb in the SQL","confidence":0.7,"observations":6,"last_seen":"2026-03-01T14:30:00Z","source":"writer-project","tags":["sqlalchemy","asyncpg","jsonb"]}
   EOF
   ```

5. Present new instincts to the user for validation. User can:
   - **Confirm**: Boost confidence by 0.1
   - **Reject**: Remove the instinct
   - **Refine**: Adjust the pattern or action

## Phase 3: EVOLVE -- Promote to Skills

When an instinct reaches confidence 0.9+ and has been validated by the user, promote it.

### Promotion Criteria
- Confidence >= 0.9
- 10+ supporting observations
- User-validated at least once
- Pattern is general enough to be useful across projects

### Promotion Process

1. Identify instincts meeting promotion criteria
2. Group related instincts that could form a single skill
3. Draft a SKILL.md file from the instinct group:
   - Pattern becomes the skill description
   - Action becomes the skill instructions
   - Observations become examples
   - Tags become the skill's discovery keywords
4. Present the draft skill to the user for review
5. On approval, write the SKILL.md file to the skills directory
6. Archive promoted instincts (mark as `evolved: true`)

## Commands

### /gs:observe [observation]
Log a new observation to the observation file.

### /gs:crystallize
Analyze all observations and form new instincts. Report findings.

### /gs:evolve
Check for instincts ready for promotion. Draft skill files for candidates.

### /gs:list
Show all current instincts sorted by confidence, with observation counts.

### /gs:export
Export instincts as a portable JSON file for sharing with team members.

### /gs:import [file]
Import instincts from a team member's export. Merge with existing instincts, averaging confidence scores for duplicates.

## Storage

```
~/.gs-orchestrator/
├── observations.jsonl    # Raw observation log (append-only)
├── instincts.jsonl       # Active instincts (read/update)
├── instincts-archive.jsonl  # Evolved/retired instincts
└── exports/              # Shared instinct files
```

## Key Principles

- **Low friction logging**: Observations should be quick to log. One line per observation.
- **Patience over speed**: Do not crystallize from fewer than 3 observations. Wait for patterns to emerge.
- **User validation matters**: Never promote an instinct without user confirmation.
- **Instincts decay**: If an instinct is not observed for 30+ days, reduce confidence by 0.1.
- **Team learning**: Instincts shared across team members accumulate faster. Use export/import.
