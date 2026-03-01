# Context Engineering -- Managing the Context Window

Reference guide for context window management when working with Claude and other LLMs. Based on the principle that the quality of LLM output is directly proportional to the quality of its context.

## The 4 Pillars

### 1. Write -- Author Clear Context

Provide the model with exactly the information it needs, in the order it needs it.

**Principles:**
- Lead with the most important information (the model attends most to the beginning and end)
- Use structured formats (XML tags, headers, tables) over prose
- State the goal before providing background
- Separate instructions from data

**Context ordering (best to worst):**
1. System prompt (highest attention)
2. First user message
3. Most recent messages
4. Middle of conversation (lowest attention -- the "lost in the middle" problem)

### 2. Select -- Choose What to Include

Not everything is relevant. Aggressive selection prevents context dilution.

**Selection criteria:**
- Is this information necessary to complete the task? (If no, exclude)
- Is this information already known from the conversation? (If yes, don't repeat)
- Would removing this change the output? (If no, exclude)

**What to include:**
- Current file contents (the code being modified)
- Error messages and stack traces (full, not truncated)
- Schema definitions (for database work)
- Type definitions (for API work)
- Test expectations (what "correct" looks like)

**What to exclude:**
- Entire files when only a function matters
- Historical context that has been superseded
- Verbose logs when a summary suffices
- Documentation the model already knows (e.g., standard library docs)

### 3. Compress -- Reduce Token Usage

When context exceeds capacity, compress rather than truncate.

**Compression techniques:**
- Summarize long documents before injecting
- Use structured data (JSON/tables) instead of prose
- Replace verbose examples with terse ones
- Use code references ("see line 45 of models.py") instead of pasting the full code
- For repeated patterns, show one example and note "N more following the same pattern"

**Signs of context rot:**
- Model starts contradicting earlier decisions
- Model "forgets" constraints from the system prompt
- Output quality degrades over a long conversation
- Model hallucinates functions or APIs that were not in context

**When to compact:**
- Conversation exceeds 50% of context window
- You notice any signs of context rot
- The PreCompact hook fires (saves state to recovery file)

### 4. Isolate -- Use Subagents for Separation

When a task has distinct phases with different context needs, use subagents to prevent cross-contamination.

**When to isolate:**
- Research phase vs implementation phase (different files, different goals)
- Analysis of multiple independent components
- Tasks that need different models (e.g., Haiku for speed, Opus for quality)
- When the main context is too full for a side task

**Subagent patterns:**
- **Reader subagent**: Reads files and summarizes them (Haiku model, Read-only tools)
- **Researcher subagent**: Investigates a question and returns findings (Sonnet model, full tools)
- **Reviewer subagent**: Reviews code without knowing how it was written (prevents confirmation bias)
- **Executor subagent**: Runs a small well-defined task and returns results

**Handoff protocol:**
- Provide the subagent with a clear task description
- Include only the context it needs (not the full conversation)
- Accept its output as a compressed summary
- The parent agent decides what to do with the results

## Context Budget Planning

For a 200K token context window:

| Allocation | Tokens | Percentage |
|-----------|--------|-----------|
| System prompt | 5-15K | 3-8% |
| CLAUDE.md + project context | 10-30K | 5-15% |
| Current conversation | 50-100K | 25-50% |
| File contents (code being worked on) | 30-60K | 15-30% |
| Tool results | 20-40K | 10-20% |
| Buffer for output | 15-30K | 8-15% |

For a 1M token context window, the ratios shift: more room for file contents and tool results, but attention quality still degrades in the middle.

## Practical Patterns

### Long File Editing

Instead of reading the entire file, read the relevant section:

```
Read lines 45-80 of src/services/writer.py (the execute_strategy method)
```

### Multi-File Context

When working across files, provide a map first:

```
Files involved:
- src/models/grant.py (data model) -- focus on GrantInstance class
- src/services/writer.py (business logic) -- focus on write_section()
- src/api/routes/writer.py (API layer) -- focus on POST /sections/{id}/write
- tests/test_writer.py (tests) -- focus on test_write_section_with_evidence()
```

### Database Context

Instead of describing the schema in prose, provide the DDL:

```sql
-- Relevant tables for this task:
CREATE TABLE writer.project_sections (
    id UUID PRIMARY KEY,
    project_instance_id UUID REFERENCES writer.project_instances(id),
    section_name TEXT NOT NULL,
    content TEXT,
    status TEXT DEFAULT 'pending'
);
```

### Conversation Checkpointing

At natural boundaries (completing a feature, switching tasks), summarize what happened:

```
CHECKPOINT: Completed the writer.project_sections repository layer.
- Created: src/repositories/project_sections.py (4 methods: create, get, update, list)
- Tests: tests/test_project_sections.py (12 tests, all passing)
- Migration: alembic/versions/003_project_sections.py
- Next: Build the service layer on top of this repository
```

This prevents context rot by creating explicit reference points.

## Anti-Patterns

- **Dumping entire codebases**: Only include files relevant to the current task
- **Repeating instructions**: If you said it in the system prompt, do not repeat it in every message
- **Ignoring context rot**: If the model contradicts itself, it is time to compact or start a new conversation
- **Skipping isolation**: Trying to do research AND implementation in the same context leads to worse results for both
- **No structure**: Free-form context is harder for the model to attend to than structured context
