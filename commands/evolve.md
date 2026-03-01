---
name: gs:evolve
description: "Cluster instincts into skills, agents, or workflow improvements. Analyzes the instinct library, groups by theme, and proposes promotions."
---

# /gs:evolve -- Evolve Instincts into Skills/Agents

You are analyzing the accumulated instinct library to find patterns worth promoting into formal skills, agent refinements, or workflow improvements.

## When to Use

- After accumulating 20+ instincts
- When you notice repeated patterns across sessions
- When the user asks to review what has been learned
- Periodically (e.g., weekly) to keep the instinct library healthy

## Evolution Protocol

### Step 1: Load and Parse Instincts

```bash
cat ~/.gs-orchestrator/instincts.jsonl 2>/dev/null
```

Parse all instincts. Report: "Loaded N instincts spanning M sessions."

### Step 2: Cluster by Theme

Group instincts by their `tags` field, looking for clusters of 3+ related instincts:

| Cluster | Instincts | Avg Confidence | Total Reinforcements |
|---------|-----------|----------------|---------------------|
| asyncpg-gotchas | 5 | 0.92 | 12 |
| prompt-engineering | 4 | 0.78 | 6 |
| temporal-workflows | 3 | 0.65 | 3 |

Also look for non-tag clusters by analyzing trigger/observation similarity.

### Step 3: Identify Promotion Candidates

An instinct cluster is ready for promotion when:

- **Skill candidate**: 3+ instincts with avg confidence >= 0.7 and combined reinforcements >= 5
  - Example: Multiple instincts about JSONB handling -> create a "database-patterns" skill
- **Agent refinement**: 2+ instincts about a specific agent's blind spots
  - Example: "debugger agent misses async race conditions" -> update debugger.md
- **Hook candidate**: 3+ instincts about recurring mistakes that could be caught automatically
  - Example: Repeated "forgot to json.dumps()" -> add a PostToolUse validation
- **Knowledge candidate**: 2+ instincts that are pure domain facts
  - Example: DB column name mismatches -> add to gs-domain.md knowledge file

### Step 4: Generate Proposals

For each promotion candidate, draft the artifact:

#### Skill Proposal

```markdown
## Proposed Skill: [name]

Based on [N] instincts with avg confidence [X.XX]:
- [instinct 1 summary]
- [instinct 2 summary]
- [instinct 3 summary]

### Draft SKILL.md

---
name: [skill-name]
description: "[description derived from instinct cluster]"
---

# [Skill Name]

[Content synthesized from the instinct cluster]

## When to Use
[Derived from instinct triggers]

## Key Patterns
[Derived from instinct actions]
```

#### Agent Refinement Proposal

```markdown
## Proposed Agent Update: [agent-name]

Based on [N] instincts:
- [instinct 1 summary]

### Suggested Addition to [agent].md

[Specific text to add to the agent definition]
```

#### Knowledge Addition Proposal

```markdown
## Proposed Knowledge Update: [file-name]

Based on [N] instincts:
- [instinct 1 summary]

### Suggested Addition

[Content to add to the knowledge file]
```

### Step 5: Prune Low-Value Instincts

Identify instincts that should be archived:

- Confidence below 0.4 with 0 reinforcements and older than 30 days
- Superseded by a promoted skill (the instinct is now encoded in the skill)
- Contradicted by newer, higher-confidence instincts

Propose archival (move to `~/.gs-orchestrator/instincts-archive.jsonl`), do not delete.

### Step 6: Report

```
EVOLUTION REPORT
================

Instinct Library: N total, M clusters identified

Promotion Candidates:
  1. SKILL: [name] (from N instincts, avg confidence X.XX)
     [one-line description]

  2. AGENT UPDATE: [agent-name] (from N instincts)
     [one-line description]

  3. KNOWLEDGE: [file] (from N instincts)
     [one-line description]

Prune Candidates: K instincts recommended for archival

Actions Available:
  - "promote [N]" -- Generate and write the proposed skill/update
  - "prune" -- Archive low-value instincts
  - "details [N]" -- Show full proposal for candidate N
  - "skip" -- No changes, review later
```

## Auto-Generation

When the user says "promote N", generate the actual file:

1. Write the SKILL.md, updated agent.md, or knowledge addition
2. Mark the source instincts as `"promoted": true` with a reference to the generated file
3. Report what was created

## Rules

- Never delete instincts -- archive them to a separate file
- Always show proposals before writing files
- The user must approve promotions (do not auto-generate)
- If two clusters overlap significantly, propose merging them into one skill
- Keep the instinct library under 200 entries (archive aggressively after that)
- Generated skills should follow the exact SKILL.md format from existing skills
