---
name: gs:learn
description: "Extract patterns and instincts from the current session. Analyzes decisions, outcomes, and observations, then crystallizes them into reusable instincts."
---

# /gs:learn -- Extract Instincts from Session

You are analyzing the current conversation to extract reusable patterns, decisions, and lessons learned. These are stored as "instincts" that inform future sessions.

## What is an Instinct?

An instinct is a crystallized observation with enough context to be actionable in future sessions. It has:

- **trigger**: When should this instinct activate? (pattern, context, situation)
- **observation**: What was noticed? (the raw fact)
- **action**: What should be done differently? (the lesson)
- **confidence**: How certain are we? (0.0 to 1.0)
- **source**: Where did this come from? (session context)

## Extraction Protocol

### Step 1: Scan the Conversation

Review the entire conversation history looking for:

1. **Debugging patterns**: Bugs that were fixed -- what was the root cause? Would it recur?
2. **Design decisions**: Choices made between alternatives -- what was the reasoning?
3. **Failures and retries**: Things that did not work the first time -- what was learned?
4. **Performance observations**: Things that were slow, things that were fast
5. **Tool usage patterns**: Effective tool combinations, tools that were not useful
6. **Domain knowledge**: GS-specific facts discovered during the session
7. **Anti-patterns**: Approaches that should be avoided in the future

### Step 2: Draft Instincts

For each observation, create an instinct entry:

```json
{
  "id": "inst-<timestamp>-<N>",
  "timestamp": "<ISO 8601>",
  "trigger": "When working with asyncpg and JSONB columns",
  "observation": "asyncpg cannot serialize Python dicts directly to JSONB",
  "action": "Always json.dumps() dict values and use CAST(:param AS jsonb) in the SQL",
  "confidence": 0.95,
  "source": {
    "session": "<session identifier or date>",
    "project": "<project name>",
    "files": ["src/repositories/writer.py"]
  },
  "tags": ["asyncpg", "jsonb", "database", "gotcha"],
  "reinforcements": 0
}
```

### Step 3: Deduplicate

Before writing, check existing instincts:

```bash
cat ~/.gs-orchestrator/instincts.jsonl 2>/dev/null
```

If a new instinct matches an existing one (same trigger + similar observation):
- Increment the existing instinct's `reinforcements` counter
- Update its `confidence` (increase by 0.05 per reinforcement, max 1.0)
- Do NOT create a duplicate

### Step 4: Write Instincts

Append new instincts to `~/.gs-orchestrator/instincts.jsonl` (one JSON object per line):

```bash
echo '<json>' >> ~/.gs-orchestrator/instincts.jsonl
```

### Step 5: Report

Present what was learned:

```
INSTINCTS EXTRACTED
===================

New Instincts (N):
  1. [trigger]: [observation] -> [action] (confidence: X.XX)
  2. [trigger]: [observation] -> [action] (confidence: X.XX)

Reinforced Instincts (M):
  1. [trigger]: reinforcements now at N (confidence: X.XX)

Total Instincts in Library: K

Top Tags: [tag1] (N), [tag2] (M), [tag3] (L)
```

## Instinct Quality Criteria

Good instincts are:
- **Specific**: "When using asyncpg with JSONB" not "When using databases"
- **Actionable**: "Use json.dumps()" not "Be careful with serialization"
- **Verifiable**: The trigger should be detectable from code context
- **Non-obvious**: Do not record things that any developer would know

Bad instincts (skip these):
- Generic best practices ("write tests", "use type hints")
- One-time issues unlikely to recur
- Subjective preferences without evidence
- Instincts with confidence below 0.3

## Confidence Scoring

| Confidence | Meaning | Example |
|------------|---------|---------|
| 0.9 - 1.0 | Verified multiple times, always true | pgvector returns strings, must json.loads() |
| 0.7 - 0.9 | Observed clearly, high confidence | ADAPT compression with emphasis=high keeps ~60% |
| 0.5 - 0.7 | Reasonable inference, needs more data | Opus tends to produce better adversarial reviews |
| 0.3 - 0.5 | Hypothesis based on limited observation | This API might have rate limits around 100/min |
| 0.0 - 0.3 | Too uncertain, do not record | |

## Rules

- Extract at least 1 instinct per session (there is always something to learn)
- Maximum 10 instincts per session (quality over quantity)
- Never record API keys, passwords, or secrets as instinct content
- Always check for duplicates before writing
- Instincts are append-only -- never delete from the file (use /gs:evolve to prune)
